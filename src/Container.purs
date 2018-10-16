module Container where

import Prelude

import Data.Maybe (Maybe(..))
import Data.Symbol (SProxy(..))
import Halogen as H
import Halogen.HTML as HH
import Halogen.HTML.Events as HE
import Halogen.HTML.Properties as HP
import UserAdd as UA

type State =
  { a :: Maybe Boolean
  , b :: Maybe Int
  , c :: Maybe String
  }

data Query a = AddUserToList String a

type ChildSlots =
  ( a :: CA.Slot Unit
  , b :: CB.Slot Unit
  , c :: CC.Slot Unit
  )

_ua = SProxy :: SProxy "UserAdd"

component :: forall m. Applicative m => H.Component HH.HTML Query Unit Void m
component =
  H.component
    { initialState: const initialState
    , render
    , eval
    , receiver: const Nothing
    }
  where

  initialState :: State
  initialState = { a: Nothing, b: Nothing, c: Nothing }

  render :: State -> H.ComponentHTML Query ChildSlots m
  render state = HH.div_
    [ HH.slot _ua _ua UA.userAdd unit listen ]

  eval :: Query ~> H.HalogenM State Query ChildSlots Void m
  eval (ReadStates next) = do
    a <- H.query _a unit (H.request CA.GetState)
    b <- H.query _b unit (H.request CB.GetCount)
    c <- H.query _c unit (H.request CC.GetValue)
    H.put { a, b, c }
    pure next

    -- 子コンポーネントからのMessageを受け取り、なにかする
  listen :: UA.Message -> Maybe (Query Unit)
  listen = Just <<< case _ of
    UA.AddedUserID id -> H.action $ AddUserToList id