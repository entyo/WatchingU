module UserTimeLine where

-- import Affjax.ResponseFormat

import Affjax (get)
import Affjax.ResponseFormat as ResponseFormat
import Data.Either (Either(..))
import Data.Maybe (Maybe(..))
import Data.Symbol (SProxy(..))
import Effect.Aff (Aff)
import Halogen as H
import Halogen.HTML as HH
import Halogen.HTML.Events as HE
import Hatena as Hatena
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
  res :: Maybe (YQL.Response Hatena.Response),
  loading :: Boolean
}

user :: String -> H.Component HH.HTML UserQuery Unit UserMessage Aff
user username =
  H.component
    { initialState: const { res: Nothing, loading: false }
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
              case state.res of
                Nothing -> []
                Just res ->
                  [ HH.ul_ (map renderItem res.query.results.item) ]
           , HH.button [ HE.onClick (HE.input_ Remove) ]
           [ HH.text "削除" ] ]

  -- queryをevalしてHalogenMにする
  eval :: UserQuery ~> H.HalogenM State UserQuery () UserMessage Aff
  eval (Remove next) = do
    H.raise Removed
    pure next
  eval (Initialize next) = do
    H.modify_ (_ { loading = true })
    response <- H.liftAff $ get (ResponseFormat.string) (Hatena.buildUrlByUserName username)
    case response.body of
      -- TODO: エラー処理をちゃんとやる
      -- Left err -> H.modify_ (_ { res = Just (printResponseFormatError err), loading = false })
      Left err -> H.modify_ (_ { res = Nothing, loading = false })
      Right body -> case (Hatena.decode body) of
        -- TODO: エラー処理をちゃんとやる
        Left _ -> H.modify_ (_ { res = Nothing, loading = false })
        Right b -> H.modify_ (_ { res = Just b, loading = false })
    pure next

renderItem :: forall f m. Hatena.Response -> H.ComponentHTML f () m
renderItem response = HH.li_ [ HH.p_ [ HH.text response.title ] ]