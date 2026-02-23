module MainSpec (spec) where

import Test.Hspec

spec :: Spec
spec = do
  describe "some property" $ do
    it "can do things" $ do
      20 `shouldBe` (18+2 :: Int)
