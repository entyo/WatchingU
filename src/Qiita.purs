module Qiita where

import Data.Either (Either)
import Data.List.Types (NonEmptyList)
import Foreign (ForeignError)
import Prelude ((<>))
import Simple.JSON (readJSON)

type Response = {
  rendered_body :: String,
  created_at :: String,
  title :: String,
  updated_at :: String,
  url :: String
}

type Response' = Array Response

buildUrlByUserName :: String -> String
buildUrlByUserName username = "https://qiita.com/api/v2/users/" <> username <> "/items"

type Decoded = Either (NonEmptyList ForeignError) Response'

decode :: String -> Decoded
decode = readJSON

-- type Response = {
  -- rendered_body :: String,
  -- coediting :: Boolean,
  -- comments_count :: Int,
  -- どこかでJSDateに変換される
  -- created_at :: String,
  -- 型が謎
  -- group: Maybe ,
  -- id :: String,
  -- likes_count :: Int,
  -- private :: Boolean,
  -- reactions_count :: Int,
  -- versionsの型が謎(Array any)
  -- tags: Array { name :: String, versions: Array String },
  -- どこかでJSDateに変換される
  -- title :: String,
  -- updated_at :: String,
  -- url :: String,
  -- user :: {
  --   description :: String,
  --   facebook_id :: String
  --   followees_count :: Int,
  --   followers_count :: Int,
  --   github_login_name :: String,
  --   id :: String,
  --   items_count :: Int,
  --   linkedin_id :: String,
  --   location :: String,
  --   name :: String,
  --   organization :: String,
  --   permanent_id :: Int,
  --   profile_image_url :: String,
  --   twitter_screen_name :: String,
  --   website_url :: String
  -- },
  -- page_views_count :: Maybe Int
-- }