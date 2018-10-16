module Main where

<<<<<<< HEAD
import Prelude

import Effect (Effect)
import Halogen.Aff as HA
import Halogen.VDom.Driver (runUI)
import UserAdd (userAdd)

=======
import Button (myButton)
import Effect (Effect)
import Halogen.Aff as HA
import Halogen.VDom.Driver (runUI)
import Prelude (bind, unit, Unit)
 
>>>>>>> 02feb4378e586dd1b3b7fc54d1347147bd163c10
main :: Effect Unit
main = HA.runHalogenAff do
  body <- HA.awaitBody
  runUI userAdd unit body