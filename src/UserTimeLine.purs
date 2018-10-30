module UserTimeLine where

import Affjax.ResponseFormat

import Affjax (get)
import Affjax.ResponseFormat as ResponseFormat
import Data.Either (Either(..))
import Data.Maybe (Maybe(..))
import Data.Symbol (SProxy(..))
import Effect.Aff (Aff)
import Effect.Console (log)
import Halogen as H
import Halogen.HTML as HH
import Halogen.HTML.Events as HE
import Prelude (type (~>), Unit, bind, const, discard, pure, ($), (<>))

-- | The task component query algebra.
data UserQuery a = Remove a | Initialize a

data UserMessage
  -- takes an userId
  = Removed

type UserSlot = H.Slot UserQuery UserMessage

_user = SProxy :: SProxy "user"

type HatenaRSSResponse = {
  description :: String,
  link :: String,
  pubDate :: String,
  title :: String,
  enclosure :: {
    length :: String,
    type :: String,
    url :: String
  }
}

type State = {
  res :: Maybe String,
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
                  [ HH.pre_ [ HH.code_ [ HH.text res ] ] ]
           , HH.button [ HE.onClick (HE.input_ Remove) ]
           [ HH.text "削除" ] ]

  -- queryをevalしてHalogenMにする
  eval :: UserQuery ~> H.HalogenM State UserQuery () UserMessage Aff
  eval (Remove next) = do
    H.raise Removed
    pure next
  eval (Initialize next) = do
    H.modify_ (_ { loading = true })
    let url = "https://query.yahooapis.com/v1/public/yql?q=select * from rss where url='http://" <> username <> ".hatenablog.com/rss'&format=json"
    H.liftEffect $ log $ url
    response <- H.liftAff $ get (ResponseFormat.string) url
    case response.body of
      Left err -> H.modify_ (_ { res = Just (printResponseFormatError err), loading = false })
      Right body -> H.modify_ (_ { res = Just body, loading = false })
    pure next
