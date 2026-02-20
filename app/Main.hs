module Main where

import qualified Data.List
import qualified Data.Maybe
import qualified System.Directory
import qualified System.Process


data TestStrategy = CabalTest | MakeTest
  deriving(Show, Eq)

dirEntToTestStrategy :: String -> Maybe TestStrategy
dirEntToTestStrategy "Makefile" = Just MakeTest
dirEntToTestStrategy ent | ".cabal" `Data.List.isSuffixOf` ent = Just CabalTest
                         | otherwise = Nothing


type TestRunner = IO ()

prepareTestRunner :: TestStrategy -> TestRunner
prepareTestRunner CabalTest = runCabalTest
prepareTestRunner MakeTest = runMakeTest

runCabalTest :: TestRunner
runCabalTest = System.Process.callCommand "cabal test"

runMakeTest :: TestRunner
runMakeTest = System.Process.callCommand "make test"

noRunnerFound :: TestRunner
noRunnerFound = putStrLn "tatt: couldn't detect test runner"


data Prefs = StubPrefs

determinePrefs :: IO Prefs
determinePrefs = return StubPrefs

betterStrat :: Prefs -> TestStrategy -> TestStrategy -> TestStrategy
betterStrat StubPrefs lhs rhs =
  case (lhs, rhs) of
    (CabalTest,_) -> CabalTest
    (_,CabalTest) -> CabalTest
    _ -> MakeTest

bestStrat :: Prefs -> [TestStrategy] -> TestStrategy
bestStrat _ [] = error "can't pick best from no choices"
bestStrat _ [it] = it
bestStrat p lst = foldr1 (betterStrat p) lst

pickTestStrategy :: Prefs -> [String] -> TestRunner
pickTestStrategy prefs dirlist =
  let possibleStrats = Data.Maybe.mapMaybe dirEntToTestStrategy dirlist
  in if null possibleStrats
    then noRunnerFound
    else prepareTestRunner $ bestStrat prefs possibleStrats


main :: IO ()
main = do
  prefs <- determinePrefs
  dirlist <- System.Directory.listDirectory "."
  pickTestStrategy prefs dirlist
