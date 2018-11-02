module YQL where

type Response a = {
  query :: {
    count :: Int,
    created :: String,
    lang :: String,
    results :: {
      item :: Array a
    }
  }
}