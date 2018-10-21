module UserList where

import Prelude

import Data.Array (filter, snoc)
import Data.Maybe (Maybe(..))
import Data.Symbol (SProxy(..))
import Halogen as H
import Halogen.HTML as HH
import Halogen.HTML.Events as HE
import UserTimeLine as UT

data Query a
  = AddUser String a
  -- Handle messages from user component
  | HandleUserMessage String UT.UserMessage a

-- TODO: Add `UserTimeLine` component, then add it to childSlots
type ChildSlots = ( user :: UT.UserSlot String )

type State = Array String

type Input = String

type Slot = H.Slot Query Void

initialS :: State
initialS = [ "user1", "user2" ]

_list = SProxy :: SProxy "userList"

-- | The list component definition.
list :: forall m. Applicative m => H.Component HH.HTML Query Unit Void m
list =
  H.component
    { initialState: const initialS
    , render
    , eval
    , receiver: const Nothing
    , initializer: Nothing
    , finalizer: Nothing
    }
  where

  render :: State -> H.ComponentHTML Query ChildSlots m
  render st =
    HH.div_
      [ HH.h2_ [ HH.text "ユーザ一覧" ]
        --   [ HH.li_ [ HH.text st ] ]
      , HH.ul_ (map renderUser st)
      ]

  renderUser :: String -> H.ComponentHTML Query ChildSlots m
  renderUser id =
    HH.slot UT._user id
      -- pass userID
      (UT.user id)
      unit
      (HE.input (HandleUserMessage id))

  eval :: Query ~> H.HalogenM State Query ChildSlots Void m
  eval (AddUser id next) = do
    H.modify_ (addUserID id)
    pure next
  eval (HandleUserMessage p msg next) = do
    case msg of
      UT.Removed -> do
        H.modify_ (removeUser p)
    pure next

-- | Adds a task to the current state.
addUserID :: String -> State -> State
addUserID uid st = st  `snoc` uid

-- | Removes a task from the current state.
removeUser :: String -> State -> State
removeUser id st = filter (_ /= id) st
