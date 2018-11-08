module Medium where

import Prelude ((<>))
import Data.Either (Either)
import Foreign (ForeignError)
import Data.List.NonEmpty (NonEmptyList)
import YQL as YQL
import Simple.JSON (readJSON)

type Response = {
  creator :: String,
  encoded :: String,
  link :: String,
  pubDate :: String,
  title :: String,
  updated :: String
}

buildUrlByUserName :: String -> String
buildUrlByUserName username = "https://query.yahooapis.com/v1/public/yql?q=select * from rss where url='https://medium.com/feed/@" <> username <> "'&format=json"

type Decoded = Either (NonEmptyList ForeignError) (YQL.Response Response)

decode :: String -> Decoded
decode = readJSON
