module Container where

import Prelude

import Data.Array (snoc)
import Data.Maybe (Maybe(..))
import Effect.Aff (Aff)
import Effect.Console (log)
import Halogen (liftEffect)
import Halogen as H
import Halogen.HTML as HH
import UserAdd as UA
import UserList as UL

type State = { userIDs :: Array String }

data Query a = ReadUserID String a

type ChildSlots =
  ( 
    -- specify slot input type(i.e. UserId)
    userAdd  :: UA.Slot Unit,
    userList :: UL.Slot Unit
  )

initialState :: State
initialState = { userIDs: ["e-ntyo", "potato4d", "akameco"] }

container :: H.Component HH.HTML Query Unit Void Aff
container =
  H.component
    { initialState: const initialState
    , render
    , eval
    , receiver: const Nothing
    , initializer: Nothing
    , finalizer: Nothing
    }
  where

  render :: State -> H.ComponentHTML Query ChildSlots Aff
  render state = HH.div_
    [ 
      HH.slot UA._userAdd unit UA.userAdd unit listen,
      HH.slot UL._list unit UL.list state.userIDs absurd
    ]

  eval :: Query ~> H.HalogenM State Query ChildSlots Void Aff
  eval (ReadUserID userID next) = do
    _userID <- H.query UA._userAdd unit (H.request UA.GetUserID)
    case _userID of
      Nothing -> do
        -- Nothing to do
        pure next
      Just uid -> do
        uids <- H.gets _.userIDs
        let userIDs = (uids `snoc` uid)
        liftEffect $ (log $ "uid: " <> uid)
        liftEffect $ (log $ "uids: " <>  show userIDs)
        H.put { userIDs }
        pure next

  -- 子コンポーネントからのMessageを受け取り、なにかする
  listen :: UA.Message -> Maybe (Query Unit)
  listen = Just <<< case _ of
    UA.AddedUserID id -> H.action $ ReadUserID id

addUserID :: String -> State -> State
-- TODO: Do not add uid if it already exists
addUserID uid st = do
  st { userIDs = st.userIDs `snoc` uid }