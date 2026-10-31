module RangeExtractor.JorgeVS.Kata where

import Data.List (intercalate)

solution :: [Integer] -> String
solution = intercalate "," . go
  where
    go [] = []
    go (x : xs) =
      let (end, rest) = spanRun x xs
       in formatRun x end ++ go rest

    spanRun prev (y : ys)
      | y == prev + 1 = spanRun y ys
    spanRun prev ys = (prev, ys)

    formatRun a b
      | b >= a + 2 = [show a ++ "-" ++ show b]
      | b == a + 1 = [show a, show b]
      | otherwise  = [show a]
