module Integration.IntegrationTestSpec where

import Data.List (elemIndices, intercalate)
import Data.List.Split (splitOn)
import Data.Maybe (fromJust)
import Safe (lastMay)
import System.Directory (doesDirectoryExist, getCurrentDirectory)
import Test.Hspec

import qualified Crypto.Hash.MD5 as MD5
import qualified Data.ByteString as B
import qualified Data.ByteString.Base16 as Hex
import qualified Data.ByteString.Char8 as BC

import qualified Integration.Repo

fileParts :: FilePath -> [FilePath]
fileParts = splitOn "/"

findThisFile :: FilePath -> Maybe [FilePath]
findThisFile dirpath =
  case lastMay $ elemIndices "tatt" parts of
    Nothing -> Nothing
    Just tattIdx -> Just $ (take (succ tattIdx) parts) ++ ["test","Integration","IntegrationTestSpec.hs"]
  where
    parts = fileParts dirpath

spec :: Spec
spec = do
  describe "for a git repo" $ do
    it "can be checked out" $ do
      -- We require that the current working directory is either the root of,
      -- or contained by, a checkout of the tatt project.
      thisFileParts <- fmap (fromJust . findThisFile) System.Directory.getCurrentDirectory
      let tattRootDir = intercalate "/" $ take (length thisFileParts - 3) thisFileParts
          vcsRef = Integration.Repo.Git tattRootDir firstTattCommitHash

      localDir <- Integration.Repo.ensureCheckout vcsRef
      localDir `shouldBe` "tatt"
    it "should make the directory exist" $ do
      System.Directory.doesDirectoryExist "tatt" `shouldReturn` True
    it "should make the expected contents" $ do
      computeMD5 filePath `shouldReturn` expectedHash

firstTattCommitHash :: String
firstTattCommitHash = "d6aecaeab3f84167545631bd2abc8812bd78290a"
filePath :: FilePath
filePath = "tatt/.gitignore"
expectedHash :: String
expectedHash = "f73199d9c1d7b9426023454ad53c32b0"

computeMD5 :: FilePath -> IO String
computeMD5 f =
  fmap (BC.unpack . Hex.encode . MD5.hash) $ B.readFile f
