module UserAdd where

import Prelude

import CSS (display, em, flex, flexGrow, height, marginLeft, padding, px, width)
import Data.Int (toNumber)
import Data.Maybe (Maybe(..))
import Data.Symbol (SProxy(..))
import Halogen as H
import Halogen.HTML as HH
import Halogen.HTML.CSS as HC
import Halogen.HTML.Events as HE
import Halogen.HTML.Properties (class_)
import Halogen.HTML.Properties as HP

type State = { userID :: Maybe String }
initialState = { userID: Nothing } :: State

data Query a
  -- query
  = GetUserID (String -> a)
  -- action
  | UpdateUserID String a
  | AddUserID a

type Slot = H.Slot Query Message

_userAdd = SProxy :: SProxy "userAdd"

-- 入力されたユーザIDを、親コンポーネント(observer)に伝える
-- つかいかた:
-- https://github.com/slamdata/purescript-halogen/blob/v4.0.0/examples/lifecycle/src/Child.purs#L59
-- https://github.com/slamdata/purescript-halogen/blob/v4.0.0/examples/lifecycle/src/Child.purs#L66
data Message = AddedUserID String

isValid :: Maybe String -> Boolean
isValid (Just name) = name /= ""
isValid Nothing = false

userAdd :: forall m. H.Component HH.HTML Query Unit Message m
userAdd =
  H.component
    { initialState: const initialState
    , render
    , eval
    , receiver: const Nothing
    , initializer: Nothing
    , finalizer: Nothing
    }
  where

  render :: State -> H.ComponentHTML Query () m
  render state =
      HH.div [ HC.style do
                 height $ px $ toNumber 80
                 padding (em 1.2) (em 1.2) (em 1.2) (em 1.2)
             ]
      [
        HH.div [ HC.style $ display flex ] 
               [
                  -- TODO: ボタンを消して、<input>内でEnterできるようにする
                  HH.input
                    [
                      HP.type_ HP.InputText,
                      HP.placeholder "@e_ntyo",
                      HE.onValueChange (HE.input UpdateUserID),
                      class_ (H.ClassName "input"),
                      HC.style $ flexGrow 1
                    ]
                  ,
                  HH.button
                    [ 
                      HP.disabled (not isValid state.userID),
                      HE.onClick (HE.input_ AddUserID),
                      class_ (H.ClassName "button"),
                      HC.style do
                        width $ px $ toNumber 100
                        marginLeft $ em 0.5
                    ]
                    [ HH.text "追加" ]
                ]
      ]

  --   eval :: Query ~> H.HalogenM State Query () Message m
  eval :: Query ~> H.HalogenM State Query () Message m
  eval = case _ of
    GetUserID reply -> do
      _userID <- H.gets _.userID
      case _userID of
        Nothing -> pure (reply "")
        Just id -> pure (reply id)
    AddUserID next -> do
      _userID <- H.gets _.userID
      case _userID of
        Nothing -> do
          H.raise $ AddedUserID ""
          pure next
        Just id -> do
          H.raise $ AddedUserID id
          pure next
    UpdateUserID id next -> do
      H.modify_ (_ { userID = Just id })
      pure next
