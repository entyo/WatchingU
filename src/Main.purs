module Main where

import Button (myButton)
import Effect (Effect)
import Halogen.Aff as HA
import Halogen.VDom.Driver (runUI)
import Prelude (bind, unit, Unit)
 
main :: Effect Unit
main = HA.runHalogenAff do
  body <- HA.awaitBody
  runUI myButton unit body