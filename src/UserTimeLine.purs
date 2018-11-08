module UserTimeLine where

-- import Affjax.ResponseFormat

import Affjax as AJ
import Affjax.ResponseFormat as ResponseFormat
import Control.Parallel (parTraverse)
import Data.Array ((!!))
import Data.Either (Either(..))
import Data.Maybe (Maybe(..))
import Data.Symbol (SProxy(..))
import Effect.Aff (Aff)
import Effect.Console (log)
import Halogen as H
import Halogen.HTML as HH
import Halogen.HTML.Events as HE
import Hatena as Hatena
import Medium as Medium
import Prelude (type (~>), Unit, bind, const, discard, map, otherwise, pure, ($))
import YQL as YQL

-- | The task component query algebra.
data UserQuery a = Remove a | Initialize a

data UserMessage
  -- takes an userId
  = Removed

type UserSlot = H.Slot UserQuery UserMessage

_user = SProxy :: SProxy "user"

type State = {
  hatena :: Maybe (YQL.Response Hatena.Response),
  medium :: Maybe (YQL.Response Medium.Response),
  loading :: Boolean
}

user :: String -> H.Component HH.HTML UserQuery Unit UserMessage Aff
user username =
  H.component
    { initialState: const { hatena: Nothing, medium: Nothing, loading: false }
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
              case state.hatena of
                Nothing -> []
                Just res ->
                  [ HH.ul_ (map renderItem (map (\x -> Hatena x) res.query.results.item)) ]
           , HH.div_
              case state.medium of
                Nothing -> []
                Just res ->
                  [ HH.ul_ (map renderItem (map (\x -> Medium x) res.query.results.item)) ]
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
    case (parseYQLResponses responses) of
      Left error -> H.liftEffect $ log $ error
      Right parsed -> H.modify_ (_ parsed)
    H.modify_ (_ { loading = false })
    pure next

data Response = Hatena Hatena.Response | Medium Medium.Response

renderItem :: forall f m. Response -> H.ComponentHTML f () m
renderItem (Hatena response) = HH.li_ [ HH.p_ [ HH.text response.title ] ]
renderItem (Medium response) = HH.li_ [ HH.p_ [ HH.text response.title ] ]

parseYQLResponses :: Array (AJ.Response (Either AJ.ResponseFormatError String)) -> Either String { hatena :: YQL.Response Hatena.Response, medium :: YQL.Response Medium.Response }
parseYQLResponses responses 
  | Just _hatena <- responses !! 0
  -- Could not match type
  -- Either t0
  -- with type
  --  Record
  , Right body <- _hatena
  , Right hatena <- Hatena.decode body
  , Just _medium <- responses !! 1
  , Right body <- _medium
  , Right medium <- Medium.decode = Right { hatena, medium }
  | otherwise = Left "Failed to parse YQL response"