module UserAdd where

import Prelude

import Data.Maybe (Maybe(..))
import Data.Symbol (SProxy(..))
import Halogen as H
import Halogen.HTML as HH
import Halogen.HTML.Events as HE
import Halogen.HTML.Properties as HP

type State = { userID :: Maybe String }
initialState = { userID: Nothing } :: State

data Query a
  -- query
  = GetUserID (String -> a)
  -- action
  | UpdateUserID String a
  | AddUserID a

-- 入力されたユーザIDを、親コンポーネント(observer)に伝える
-- つかいかた:
-- https://github.com/slamdata/purescript-halogen/blob/v4.0.0/examples/lifecycle/src/Child.purs#L59
-- https://github.com/slamdata/purescript-halogen/blob/v4.0.0/examples/lifecycle/src/Child.purs#L66
data Message = AddedUserID String

_user = SProxy :: SProxy "user"

userAdd :: forall m. H.Component HH.HTML Query Unit Message m
userAdd =
  H.component
    { initialState: const initialState
    , render
    , eval
    , receiver: const Nothing
    }
  where

  render :: State -> H.ComponentHTML Query
  render state =
      HH.div_
      [
        -- TODO: ボタンを消して、<input>内でEnterできるようにする
        HH.input
          [
            HP.type_ HP.InputText,
            HP.placeholder "@e_ntyo",
            HE.onValueChange (HE.input UpdateUserID)
          ]
      ,
        HH.button
          [ HE.onClick (HE.input_ AddUserID) ]
          [ HH.text "追加" ]
      ]

  --   eval :: Query ~> H.HalogenM State Query () Message m
  eval :: Query ~> H.ComponentDSL State Query Message m
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
