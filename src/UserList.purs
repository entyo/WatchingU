module UserList where

import Prelude

import CSS (em, height, margin, marginBottom, marginTop, padding, pct, px)
import CSS.Flexbox (flexGrow)
import Data.Array (filter, snoc)
import Data.Maybe (Maybe(..))
import Data.Symbol (SProxy(..))
import Effect.Aff (Aff)
import Effect.Console (log)
import Halogen (liftEffect)
import Halogen as H
import Halogen.HTML as HH
import Halogen.HTML.CSS as HC
import Halogen.HTML.Events as HE
import Halogen.HTML.Properties (class_, classes)
import UserTimeLine as UT

data Query a
  = AddUser String a
  -- Handle messages from user component
  | HandleUserMessage String UT.UserMessage a
  | HandleInput Input a

-- TODO: バグ！Messageを使ってContainerのStateで管理しているidリストからidを削除するようにする

type ChildSlots = ( user :: UT.UserSlot String )

type State = Array String

type Input = Array String

type Slot = H.Slot Query Void


_list = SProxy :: SProxy "userList"

-- | The list component definition.
list :: H.Component HH.HTML Query Input Void Aff
list =
  H.component
    -- To reflect input value to initial state
    { initialState: identity
    , render
    , eval
    , receiver: HE.input HandleInput
    , initializer: Nothing
    , finalizer: Nothing
    }
  where

  render :: State -> H.ComponentHTML Query ChildSlots Aff
  render st =
    HH.div [ HC.style do
               flexGrow 1
               padding (em 0.5) (em 0.5) (em 0.5) (em 0.5)
            ]
            [ HH.div_ [
                HH.div [
                  class_ (H.ClassName "columns"),
                  HC.style do
                    margin (px 0.0) (px 0.0) (px 0.0) (px 0.0)
                    height $ pct $ 90.0
                ]
                (map renderUser st)
            ]
      ]

  renderUser :: String -> H.ComponentHTML Query ChildSlots Aff
  renderUser id =
    HH.div
      [ class_ (H.ClassName "column") ]
      [ HH.slot UT._user id
        -- pass userID
        (UT.user id)
        unit
        (HE.input (HandleUserMessage id))
      ]

  eval :: Query ~> H.HalogenM State Query ChildSlots Void Aff
  eval (AddUser id next) = do
    H.modify_ (addUserID id)
    pure next
  eval (HandleUserMessage p msg next) = do
    case msg of
      UT.Removed -> do
        H.modify_ (removeUser p)
    pure next
  -- > Calling put or modify in eval will always cause a component to re-render, so by checking whether the state changes first we can prevent unnecessary rendering being done for this component.
  -- https://github.com/slamdata/purescript-halogen/blob/master/docs/5%20-%20Parent%20and%20child%20components.md
  eval (HandleInput newList next) = do
    oldList <- H.get
    when (oldList /= newList) $ H.put newList
    liftEffect $ (log $ "oldList: " <> show oldList)
    liftEffect $ (log $ "newList: " <> show newList)
    pure next

-- | Adds a task to the current state.
addUserID :: String -> State -> State
addUserID uid st = st  `snoc` uid

-- | Removes a task from the current state.
removeUser :: String -> State -> State
removeUser id st = filter (_ /= id) st
