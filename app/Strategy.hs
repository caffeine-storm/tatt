module Strategy(TestStrategy(..), dirEntToTestStrategy, bestStrat, pickTestStrategy) where

import qualified Data.List
import qualified Data.Maybe

import qualified Prefs

data TestStrategy = CabalTest | MakeTest (Maybe String)
  deriving(Show, Eq)

dirEntToTestStrategy :: String -> Maybe TestStrategy
-- need to invoke make to find out if 'test' or 'check' are targets
dirEntToTestStrategy "Makefile" = Just $ MakeTest Nothing
dirEntToTestStrategy ent | ".cabal" `Data.List.isSuffixOf` ent = Just CabalTest
                         | otherwise = Nothing


betterStrat :: Prefs.Prefs -> TestStrategy -> TestStrategy -> TestStrategy
betterStrat Prefs.StubPrefs lhs rhs =
  case (lhs, rhs) of
    (CabalTest,_) -> CabalTest
    (_,CabalTest) -> CabalTest
    _ -> lhs

bestStrat :: Prefs.Prefs -> [TestStrategy] -> TestStrategy
bestStrat _ [] = error "can't pick best from no choices"
bestStrat _ [it] = it
bestStrat p lst = foldr1 (betterStrat p) lst

pickTestStrategy :: Prefs.Prefs -> [String] -> Maybe TestStrategy
pickTestStrategy prefs dirlist =
  let possibleStrats = Data.Maybe.mapMaybe dirEntToTestStrategy dirlist
  in if null possibleStrats
    then Nothing
    else Just $ bestStrat prefs possibleStrats
