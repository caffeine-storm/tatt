module Main where

import qualified System.Directory

import qualified Prefs
import qualified Runner

main :: IO ()
main = do
  prefs <- Prefs.determinePrefs
  dirlist <- System.Directory.listDirectory "."
  Runner.pickTestRunner prefs dirlist
