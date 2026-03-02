module Graphviz.IntegrationTestSpec where

import Test.Hspec
import Graphviz.Repo

readRepoInfo :: IO VcsRef
readRepoInfo = fmap read $ readFile "test/Graphviz/upstream.git"

spec :: Spec
spec = beforeAll readRepoInfo specGivenRepo

specGivenRepo :: SpecWith VcsRef
specGivenRepo = do
  describe "for an external repo" $ do
    context "assuming it's already cloned" $ do
      it "is checked out" $ \vcsRef -> do
        -- isCheckedOut vcsRef `shouldBe` True
        pendingWith "need to implement"
