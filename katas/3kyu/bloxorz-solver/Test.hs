module Main where

import Bloxorz (bloxSolver)
import Control.Monad (unless)
import System.Exit (exitFailure)

data Pose = Upright Int Int | Horz Int Int | Vert Int Int
  deriving (Eq, Show)

simulate :: [String] -> String -> Bool
simulate [] _ = False
simulate grid@(firstRow : _) moves =
  let h = length grid
      w = length firstRow
      at r c = r >= 0 && r < h && c >= 0 && c < w && (grid !! r !! c) /= '0'
      valid (Upright r c) = at r c
      valid (Horz r c)    = at r c && at r (c + 1)
      valid (Vert r c)    = at r c && at (r + 1) c
      findCh ch =
        case [(r, c) | r <- [0 .. h - 1], c <- [0 .. w - 1], grid !! r !! c == ch] of
          (p : _) -> p
          []      -> (0, 0)
      (sr, sc) = findCh 'B'
      (xr, xc) = findCh 'X'
      step (Upright r c) 'U' = Vert (r - 2) c
      step (Upright r c) 'D' = Vert (r + 1) c
      step (Upright r c) 'L' = Horz r (c - 2)
      step (Upright r c) 'R' = Horz r (c + 1)
      step (Horz r c) 'U'    = Horz (r - 1) c
      step (Horz r c) 'D'    = Horz (r + 1) c
      step (Horz r c) 'L'    = Upright r (c - 1)
      step (Horz r c) 'R'    = Upright r (c + 2)
      step (Vert r c) 'U'    = Upright (r - 1) c
      step (Vert r c) 'D'    = Upright (r + 2) c
      step (Vert r c) 'L'    = Vert r (c - 1)
      step (Vert r c) 'R'    = Vert r (c + 1)
      step p _               = p
      walk p [] = p == Upright xr xc
      walk p (m : ms) =
        let p' = step p m
         in valid p' && walk p' ms
   in walk (Upright sr sc) moves

tests :: [([String], Int)]
tests =
  [ ( [ "1110000000"
      , "1B11110000"
      , "1111111110"
      , "0111111111"
      , "0000011X11"
      , "0000001110"
      ]
    , 7
    )
  , ( [ "0000001111111000"
      , "1111001111011000"
      , "1111111111011111"
      , "1B11000000011X11"
      , "1111000000011111"
      , "0000000000001110"
      ]
    , 14
    )
  , ( [ "000001X11"
      , "B11111111"
      , "000011100"
      , "000011100"
      ]
    , 7
    )
  , ( [ "00001110000000000000"
      , "00001111111100000000"
      , "00001000001100000000"
      , "01111111001100000000"
      , "01B10011101100000000"
      , "01100011111110000000"
      , "01100011111110000000"
      , "00000000000011100000"
      , "00000000000011100000"
      , "00001111111111111000"
      , "01111101110000000000"
      , "01101111110011111111"
      , "011111001111111011X1"
      , "01100000011101001111"
      ]
    , 29
    )
  ]

main :: IO ()
main = do
  mapM_
    ( \(grid, expectedLen) -> do
        let ans = bloxSolver grid
        unless (simulate grid ans && length ans == expectedLen) $ do
          putStrLn ("FAILED on grid; got: " ++ ans ++ " (len " ++ show (length ans) ++ ", expected " ++ show expectedLen ++ ")")
          exitFailure
    )
    tests
  putStrLn "ALL HASKELL BLOXORZ SUITES PASSED!"
