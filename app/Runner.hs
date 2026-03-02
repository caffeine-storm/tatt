module Runner(TestRunner, pickTestRunner) where

import qualified System.Process
import qualified Data.Maybe

import qualified Prefs
import qualified Strategy

type TestRunner = IO ()

prepareTestRunner :: Strategy.TestStrategy -> TestRunner
prepareTestRunner Strategy.CabalTest = runCabalTest
prepareTestRunner Strategy.MakeTest = runMakeTest
prepareTestRunner Strategy.MakeCheck = runMakeCheck

runCabalTest :: TestRunner
runCabalTest = System.Process.callCommand "cabal test"

runMakeCheck :: TestRunner
runMakeCheck = System.Process.callCommand "make check"

runMakeTest :: TestRunner
runMakeTest = System.Process.callCommand "make test"

noRunnerFound :: TestRunner
noRunnerFound = putStrLn "tatt: couldn't detect test runner"

pickTestRunner :: Prefs.Prefs -> [String] -> TestRunner
pickTestRunner prefs dirlist =
  Data.Maybe.maybe noRunnerFound prepareTestRunner $ Strategy.pickTestStrategy prefs dirlist
