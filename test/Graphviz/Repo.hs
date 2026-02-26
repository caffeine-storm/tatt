module Repo(VcsRef(..)) where

data VcsRef = Git {
  url :: String,
  hash :: String
} deriving (Show, Read, Eq, Ord)
