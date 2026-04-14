module Integration.Repo(VcsRef(..), ensureCheckout) where

import Control.Monad (unless)
import Data.List (elemIndices, isSuffixOf)
import Safe (lastMay)
import System.Directory (doesDirectoryExist)
import System.Exit (ExitCode(..))
import System.Process (proc, waitForProcess, withCreateProcess, CreateProcess(..))

data VcsRef = Git {
  upstreamUrl :: String,
  hash :: String
} deriving (Show, Read, Eq, Ord)

localPath :: VcsRef -> FilePath
localPath (Git{upstreamUrl=repoUrl}) =
  case lastMay $ elemIndices '/' repoUrl of
    Nothing -> error $ "there weren't any slashes in the upstreamUrl '" ++ repoUrl ++ "'"
    Just pos -> withoutDotGit $ drop (succ pos) repoUrl

  where
    withoutDotGit :: String -> String
    withoutDotGit s =
      if ".git" `isSuffixOf` s
        then take (length s - length ".git") s
        else s

-- throws an error if the command returns non-zero
createAndWaitProcess :: System.Process.CreateProcess -> IO ()
createAndWaitProcess proclet =
  withCreateProcess proclet $ \_ _ _ procH -> do
    ec <- waitForProcess procH
    unless (ec == ExitSuccess) $ error $ (show $ cmdspec proclet) ++ " failed with error code " ++ show ec

cloneProject :: VcsRef -> FilePath -> IO ()
cloneProject ref dir =
  -- Although it says clone, we're doing a shallow-clone; we'll only get the
  -- data for the commit we pass.
  let proclet = proc "git" ["clone", upstreamUrl ref, "--revision", hash ref, dir]
  in createAndWaitProcess proclet

setCheckoutState :: VcsRef -> FilePath -> IO ()
setCheckoutState ref dir =
  let proclet = proc "git" ["reset", "--hard", hash ref]
  in createAndWaitProcess $ proclet { cwd = Just dir }

ensureCheckout :: VcsRef -> IO FilePath
ensureCheckout ref = do
  let localDir = localPath ref
  dirExists <- doesDirectoryExist localDir
  if not dirExists
    then cloneProject ref localDir
    else setCheckoutState ref localDir
  return localDir
