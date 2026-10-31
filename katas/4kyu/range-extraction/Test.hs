module Main where

import Control.Monad (unless)
import RangeExtractor.JorgeVS.Kata (solution)
import System.Exit (exitFailure)

tests :: [([Integer], String)]
tests =
  [ ( [-6, -3, -2, -1, 0, 1, 3, 4, 5, 7, 8, 9, 10, 11, 14, 15, 17, 18, 19, 20]
    , "-6,-3-1,3-5,7-11,14,15,17-20"
    )
  , ( [-10, -9, -8, -6, -3, -2, -1, 0, 1, 3, 4, 5, 7, 8, 9, 10, 11, 14, 15, 17, 18, 19, 20]
    , "-10--8,-6,-3-1,3-5,7-11,14,15,17-20"
    )
  , ( [-3, -2, -1, 2, 10, 15, 16, 18, 19, 20]
    , "-3--1,2,10,15,16,18-20"
    )
  , ([1, 2, 3, 4, 5], "1-5")
  , ([1, 2, 4, 5], "1,2,4,5")
  , ([42], "42")
  , ([], "")
  ]

main :: IO ()
main = do
  mapM_
    ( \(inp, expected) -> do
        let got = solution inp
        unless (got == expected) $ do
          putStrLn ("FAILED: got " ++ show got ++ ", expected " ++ show expected)
          exitFailure
    )
    tests
  putStrLn "ALL HASKELL RANGE_EXTRACTION SUITES PASSED!"
