module UserTimeLine where

import Prelude

import Data.Maybe (Maybe(..))
import Data.Symbol (SProxy(..))
import Halogen as H
import Halogen.HTML as HH

-- | The task component query algebra.
data UserQuery a = Remove a

data UserMessage
  -- takes an userId
  = Removed

type UserSlot = H.Slot UserQuery UserMessage

_user = SProxy :: SProxy "user"

user :: forall m. String -> H.Component HH.HTML UserQuery Unit UserMessage m
user initialState =
  H.component
    { initialState: const initialState
    , render
    , eval
    , receiver: const Nothing
    , initializer: Nothing
    , finalizer: Nothing
    }
  where

  render :: String -> H.ComponentHTML UserQuery () m
  render state =
    HH.li_ [ HH.text state ]

  -- queryをevalしてHalogenMにする
  eval :: UserQuery ~> H.HalogenM String UserQuery () UserMessage m
  eval (Remove next) = do
    H.raise Removed
    pure next
