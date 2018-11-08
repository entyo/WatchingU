module Hatena where

import Prelude ((<>))
import Data.Either (Either)
import Foreign (ForeignError)
import Data.List.NonEmpty (NonEmptyList)
import YQL as YQL
import Simple.JSON (readJSON)

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

buildUrlByUserName :: String -> String
buildUrlByUserName username = "https://query.yahooapis.com/v1/public/yql?q=select * from rss where url='http://" <> username <> ".hatenablog.com/rss'&format=json"

type Decoded = Either (NonEmptyList ForeignError) (YQL.Response Response)

decode :: String -> Decoded
decode = readJSON