module Hatena where

import Data.Either (Either)
import Data.List.NonEmpty (NonEmptyList)
import Data.String (Pattern(..), Replacement(..), replaceAll)
import Foreign (ForeignError)
import Prelude ((<>))
import Simple.JSON (readJSON)
import YQL as YQL

type Response = {
  description :: String,
  link :: String,
  pubDate :: String,
  title :: String,
  enclosure :: {
    -- i.e.) "0", "1"
    length :: String,
    type :: String,
    url :: String
  }
}

hatenize :: String -> String
hatenize = replaceAll (Pattern "_") (Replacement "-")

buildUrlByUserName :: String -> String
buildUrlByUserName username = "https://query.yahooapis.com/v1/public/yql?q=select * from rss where url='http://" <> hatenize username <> ".hatenablog.com/rss'&format=json"

type Decoded = Either (NonEmptyList ForeignError) (YQL.Response Response)

decode :: String -> Decoded
decode = readJSON