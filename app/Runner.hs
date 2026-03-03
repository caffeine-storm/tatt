module Runner(TestRunner, pickTestRunner) where

import qualified System.Process as Proc
import qualified System.Exit as Exit
import qualified Data.Maybe

import qualified Prefs
import qualified Strategy

type TestRunner = IO ()

prepareTestRunner :: Strategy.TestStrategy -> TestRunner
prepareTestRunner Strategy.CabalTest = runCabalTest
prepareTestRunner (Strategy.MakeTest (Just aRecipe)) = runMakeTest aRecipe
prepareTestRunner (Strategy.MakeTest Nothing) =
  pickTestRecipe >>= runMakeTest

pickTestRecipe :: IO String
pickTestRecipe = do
  checkExists <- recipeExists "check"
  testExists <- recipeExists "test"
  if checkExists
    then return "check"
    else if testExists
      then return "test"
      else error $ "tatt: couldn't detect test recipe for Makefile"
  where
    recipeExists :: String -> IO Bool
    recipeExists recipe = do
      stat <- Proc.spawnCommand ("make " ++ recipe) >>= Proc.waitForProcess
      case stat of
        Exit.ExitSuccess -> return True
        (Exit.ExitFailure _) -> return False

runCabalTest :: TestRunner
runCabalTest = Proc.callCommand "cabal test"

runMakeTest :: String -> TestRunner
runMakeTest recipe = Proc.callCommand $ "make " ++ recipe

noRunnerFound :: TestRunner
noRunnerFound = putStrLn "tatt: couldn't detect test runner"

pickTestRunner :: Prefs.Prefs -> [String] -> TestRunner
pickTestRunner prefs dirlist =
  Data.Maybe.maybe noRunnerFound prepareTestRunner $ Strategy.pickTestStrategy prefs dirlist
