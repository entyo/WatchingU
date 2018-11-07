module UserTimeLine where

-- import Affjax.ResponseFormat

import Affjax (get)
import Affjax.ResponseFormat as ResponseFormat
import Control.Parallel (parTraverse)
import Data.Array ((!!))
import Data.Either (Either(..))
import Data.Maybe (Maybe(..))
import Data.Symbol (SProxy(..))
import Effect.Aff (Aff)
import Halogen as H
import Halogen.HTML as HH
import Halogen.HTML.Events as HE
import Hatena as Hatena
import Medium as Medium
import Prelude (type (~>), Unit, bind, const, discard, map, pure, ($))
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
    responses <- H.liftAff $ parTraverse (get ResponseFormat.string) urls
    H.modify_ (_ { loading = false })
    -- TODO: これはヤバいから直す
    let _hatena = responses !! 0
    case _hatena of
      Nothing -> H.modify_ (_ { hatena = Nothing })
      Just hatena ->
        case hatena.body of
          Left err -> H.modify_ (_ { hatena = Nothing })
          Right body -> case (Hatena.decode body) of
            Left _ -> H.modify_ (_ { hatena = Nothing })
            Right b -> H.modify_ (_ { hatena = Just b })
    let _medium = responses !! 1
    case _medium of
      Nothing -> H.modify_ (_ { medium = Nothing })
      Just medium ->
        case medium.body of
          Left err -> H.modify_ (_ { medium = Nothing })
          Right body -> case (Medium.decode body) of
            Left _ -> H.modify_ (_ { medium = Nothing })
            Right b -> H.modify_ (_ { medium = Just b })
    pure next

data Response = Hatena Hatena.Response | Medium Medium.Response

renderItem :: forall f m. Response -> H.ComponentHTML f () m
renderItem (Hatena response) = HH.li_ [ HH.p_ [ HH.text response.title ] ]
renderItem (Medium response) = HH.li_ [ HH.p_ [ HH.text response.title ] ]
