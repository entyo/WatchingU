module UserTimeLine where

import Affjax as AJ
import Affjax.ResponseFormat as ResponseFormat
import Control.Parallel (parTraverse)
import Data.Array (sortBy, zip, (!!))
import Data.Either (Either(..))
import Data.JSDate (JSDate, parse)
import Data.Maybe (Maybe(..))
import Data.Symbol (SProxy(..))
import Data.Traversable (traverse)
import Data.Tuple (fst, snd)
import Effect.Aff (Aff)
import Effect.Console (log)
import Halogen as H
import Halogen.HTML as HH
import Halogen.HTML.Events as HE
import Halogen.HTML.Properties as HP
import Hatena as Hatena
import Medium as Medium
import Prelude (type (~>), Unit, append, bind, compare, const, discard, map, otherwise, pure, show, ($))

-- | The task component query algebra.
data UserQuery a = Remove a | Initialize a

data UserMessage
  -- takes an userId
  = Removed

type UserSlot = H.Slot UserQuery UserMessage

_user = SProxy :: SProxy "user"

type State = {
  items :: Maybe (Array TimeLineItem'),
  loading :: Boolean
}

user :: String -> H.Component HH.HTML UserQuery Unit UserMessage Aff
user username =
  H.component
    { initialState: const { items: Nothing, loading: false }
    , render
    , eval
    , receiver: const Nothing
    , initializer: Just (H.action Initialize)
    , finalizer: Nothing
    }
  where

  render :: State -> H.ComponentHTML UserQuery () Aff
  render state =
    HH.li_ [ HH.text username
           , HH.p_ [ HH.text (if state.loading then "Fetching..." else "") ]
           , HH.div_
              case state.items of
                Nothing -> []
                Just items ->
                  [ HH.ul_ (map renderItem items) ]
           , HH.button [ HE.onClick (HE.input_ Remove) ]
           [ HH.text "削除" ] ]

  -- queryをevalしてHalogenMにする
  eval :: UserQuery ~> H.HalogenM State UserQuery () UserMessage Aff
  eval (Remove next) = do
    H.raise Removed
    pure next
  eval (Initialize next) = do
    H.modify_ (_ { loading = true })
    let urls = map (\f -> f username) [Hatena.buildUrlByUserName, Medium.buildUrlByUserName]
    -- TODO: MonadError でエラーハンドリング https://github.com/slamdata/purescript-aff#2-monaderror
    responses <- H.liftAff $ parTraverse (AJ.get ResponseFormat.string) urls
    H.modify_ (_ { loading = false })
    case (parseYQLResponses responses) of
      Left error -> H.liftEffect $ log $ error
      Right parsed -> do
        let hatena = parsed.hatena
        case hatena of
          Left errors -> H.liftEffect $ log $ show errors
          Right body -> do
            let response = map Hatena body.query.results.item
            let items = map mapResponseToItem response
            let times = map (\x -> x.updatedAt) items
            times' <- H.liftEffect $ traverse parse times
            let zipped = zip items times'
            let items' = map (\x -> (fst x) { updatedAt = snd x }) zipped
            H.modify_ (addItems items')
        let medium = parsed.medium
        case medium of
          Left errors -> H.liftEffect $ log $ show errors
          Right body -> do
            let response = map Medium body.query.results.item
            let items = map mapResponseToItem response
            let times = map (\x -> x.updatedAt) items
            times' <- H.liftEffect $ traverse parse times
            let zipped = zip items times'
            let items' = map (\x -> (fst x) { updatedAt = snd x }) zipped
            H.modify_ (addItems items')
    pure next

addItems :: (Array TimeLineItem') -> State -> State
addItems items s = do
  case s.items of
    Nothing -> s { items = Just items }
    -- Sort by desc.
    Just oldItems -> s { items = Just (sortBy (\a b -> b.updatedAt `compare` a.updatedAt)  (append oldItems items)) }

data Response = Hatena Hatena.Response | Medium Medium.Response

renderItem :: forall f m. TimeLineItem' -> H.ComponentHTML f () m
renderItem item
  | Just tUrl <- item.thumbnailUrl = HH.li_ [ HH.a [ HP.href item.url ] [HH.p_ [ HH.text item.title ] ], HH.img [ HP.src tUrl ] ] 
  | otherwise = HH.li_ [ HH.a [ HP.href item.url ] [HH.p_ [ HH.text item.title ] ] ]


type YQLResponse = AJ.Response (Either AJ.ResponseFormatError String)
type Expected = { hatena :: Hatena.Decoded, medium :: Medium.Decoded }

parseYQLResponses :: Array YQLResponse -> Either String Expected
parseYQLResponses responses 
  | Just _hatena <- responses !! 0
  , Right hbody <- _hatena.body
  , Just _medium <- responses !! 1
  , Right mbody <- _medium.body = do
    let hatena = Hatena.decode hbody
    let medium = Medium.decode mbody
    Right { hatena, medium }
  | otherwise =
    Left "Failed to parse YQL response"

type TimeLineItem = {
  title :: String,
  body :: Body,
  url :: String,
  updatedAt :: String,
  thumbnailUrl :: Maybe String
}

type TimeLineItem' = {
  title :: String,
  body :: Body,
  url :: String,
  updatedAt :: JSDate,
  thumbnailUrl :: Maybe String
}

data Body = Text String | HTML String

mapResponseToItem :: Response -> TimeLineItem
mapResponseToItem (Hatena response) = { 
  title: response.title,
  body: HTML response.description,
  url: response.link,
  updatedAt: response.pubDate,
  thumbnailUrl: Just response.enclosure.url
}
mapResponseToItem (Medium response) = {
  title: response.title,
  body: HTML response.encoded,
  url: response.link,
  updatedAt: response.pubDate,
  thumbnailUrl: Nothing
}