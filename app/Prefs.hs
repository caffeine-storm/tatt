module Prefs where

data Prefs = StubPrefs

determinePrefs :: IO Prefs
determinePrefs = return StubPrefs
