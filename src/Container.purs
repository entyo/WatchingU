module Container where

import Prelude

import Data.Array (snoc)
import Data.Maybe (Maybe(..))
import Data.Symbol (SProxy(..))
import Effect.Class.Console (log)
import Halogen as H
import Halogen.HTML as HH
import UserAdd as CA
import UserAdd as UA

type State = { userIDs :: Array String }

data Query a = ReadUserID String a

type ChildSlots =
  ( 
    -- specify slot input type(i.e. TaskId)
    userAdd :: UA.Slot Unit
  )

_ua = SProxy :: SProxy "userAdd"

initialState :: State
initialState = { userIDs: [] }

component :: forall m. Applicative m => H.Component HH.HTML Query Unit Void m
component =
  H.component
    { initialState: const initialState
    , render
    , eval
    , receiver: const Nothing
    , initializer: Nothing
    , finalizer: Nothing
    }
  where

  render :: State -> H.ComponentHTML Query ChildSlots m
  render state = HH.div_
    [ HH.slot _ua unit UA.userAdd unit listen ]

  eval :: Query ~> H.HalogenM State Query ChildSlots Void m
  eval (ReadUserID userID next) = do
    _userID <- H.query _ua unit (H.request CA.GetUserID)
    case _userID of
      Nothing -> do
        -- Nothing to do
        pure next
      Just uid -> do
        uids <- H.gets _.userIDs
        let userIDs = (uids `snoc` uid)
        H.put { userIDs }
        pure next

  -- 子コンポーネントからのMessageを受け取り、なにかする
  listen :: UA.Message -> Maybe (Query Unit)
  listen = Just <<< case _ of
    UA.AddedUserID id -> H.action $ ReadUserID id

addUserID :: String -> State -> State
addUserID uid st = st { userIDs = st.userIDs `snoc` uid }
