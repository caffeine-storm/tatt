module Graphviz.Repo(VcsRef(..), isCheckedOut) where

data VcsRef = Git {
  upstreamUrl :: String,
  hash :: String
} deriving (Show, Read, Eq, Ord)

isCheckedOut :: VcsRef -> Bool
isCheckedOut _ = False
