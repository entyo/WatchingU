module Container where

import Prelude

import CSS (color, column, display, em, flex, flexDirection, height, padding, vh, whitesmoke)
import Data.Array (snoc)
import Data.Int (toNumber)
import Data.Maybe (Maybe(..))
import Data.Symbol (SProxy(..))
import Effect.Aff (Aff)
import Effect.Console (log)
import Halogen (liftEffect)
import Halogen as H
import Halogen.HTML as HH
import Halogen.HTML.CSS as HC
import Halogen.HTML.Properties (class_, classes)
import Halogen.HTML.Properties.ARIA (role)
import UserAdd as UA
import UserList as UL

type State = { userIDs :: Array String }

data Query a = ReadUserID String a

type Slot = H.Slot Query Void

_container = SProxy :: SProxy "container"

type ChildSlots =
  ( 
    -- specify slot input type(i.e. UserId)
    userAdd  :: UA.Slot Unit,
    userList :: UL.Slot Unit
  )

initialState :: State
initialState = { userIDs: [] }

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
  render state =
    HH.div [ HC.style do
               display flex
               flexDirection column
               height $ vh $ toNumber 100
           ]
           [
             HH.nav [ classes [H.ClassName "navbar", H.ClassName "is-dark"]
                      ,
                      role "navigation"
                      ,
                      HC.style $ height $ vh $ toNumber 5
                      -- ,
                      -- aria-label="main navigation">
                    ]
                    [ HH.div [ class_ (H.ClassName "navbar-bland") ]
                             [ HH.p [ HC.style do
                                        color whitesmoke
                                        padding (em 0.5) (em 0.5) (em 0.5) (em 0.5)
                                      ,
                                      class_ $ H.ClassName "title"
                                    ]
                                    [ HH.text "WatchingU" ] 
                             ]
                    ]
             ,
             HH.div [ HC.style do
                        display flex
                        flexDirection column
                        height $ vh $ toNumber 95
                    ]
                    [
                      HH.slot UA._userAdd unit UA.userAdd unit listen
                      ,
                      HH.slot UL._list unit UL.list state.userIDs absurd
                    ]
           ]

  eval :: Query ~> H.HalogenM State Query ChildSlots Void Aff
  eval (ReadUserID userID next) = do
    _userID <- H.query UA._userAdd unit (H.request UA.GetUserID)
    case _userID of
      Nothing -> do
        -- Nothing to do
        pure next
      Just uid -> do
        uids <- H.query UL._list unit (H.request UL.GetUserIDs)
        case uids of
          Nothing -> pure next
          Just ids -> do
            let userIDs = (ids `snoc` uid)
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
