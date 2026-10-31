module Bloxorz (bloxSolver) where

import Data.Array (Array, bounds, inRange, listArray, (!))
import Data.Sequence (Seq ((:<|)), (|>))
import qualified Data.Sequence as Seq
import qualified Data.Set as Set

-- | Pose of the 1x1x2 cuboid on the grid:
--   * Upright r c : standing 1x1 on (r, c)
--   * Horz    r c : lying 1x2 horizontally on (r, c) and (r, c + 1)
--   * Vert    r c : lying 2x1 vertically on (r, c) and (r + 1, c)
data Pose
  = Upright !Int !Int
  | Horz !Int !Int
  | Vert !Int !Int
  deriving (Eq, Ord, Show)

bloxSolver :: [String] -> String
bloxSolver [] = ""
bloxSolver rows@(firstRow : _) =
  let h = length rows
      w = length firstRow
      grid :: Array (Int, Int) Char
      grid = listArray ((0, 0), (h - 1, w - 1)) (concat rows)

      findChar target =
        case [ (r, c)
             | r <- [0 .. h - 1]
             , c <- [0 .. w - 1]
             , grid ! (r, c) == target
             ] of
          (p : _) -> p
          []      -> (0, 0)

      (sr, sc) = findChar 'B'
      (xr, xc) = findChar 'X'
      startPose = Upright sr sc
      goalPose = Upright xr xc

      validTile r c =
        inRange (bounds grid) (r, c) && grid ! (r, c) /= '0'

      validPose (Upright r c) = validTile r c
      validPose (Horz r c)    = validTile r c && validTile r (c + 1)
      validPose (Vert r c)    = validTile r c && validTile (r + 1) c

      neighbors (Upright r c) =
        [ ('U', Vert (r - 2) c)
        , ('D', Vert (r + 1) c)
        , ('L', Horz r (c - 2))
        , ('R', Horz r (c + 1))
        ]
      neighbors (Horz r c) =
        [ ('U', Horz (r - 1) c)
        , ('D', Horz (r + 1) c)
        , ('L', Upright r (c - 1))
        , ('R', Upright r (c + 2))
        ]
      neighbors (Vert r c) =
        [ ('U', Upright (r - 1) c)
        , ('D', Upright (r + 2) c)
        , ('L', Vert r (c - 1))
        , ('R', Vert r (c + 1))
        ]

      bfs :: Seq (Pose, String) -> Set.Set Pose -> String
      bfs Seq.Empty _ = ""
      bfs ((pose, revPath) :<| q) seen
        | pose == goalPose = reverse revPath
        | otherwise =
            let nexts =
                  [ (np, mv : revPath)
                  | (mv, np) <- neighbors pose
                  , validPose np
                  , Set.notMember np seen
                  ]
                seen' = foldl (\s (np, _) -> Set.insert np s) seen nexts
                q' = foldl (|>) q nexts
             in bfs q' seen'
   in bfs (Seq.singleton (startPose, "")) (Set.singleton startPose)
