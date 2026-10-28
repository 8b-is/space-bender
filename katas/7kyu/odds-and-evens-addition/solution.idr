module Solution

import Preloaded

-- Platform-faithful file: Codewars runs this kata on **Idris 1.3**
-- (%access export + %default total directives are Idris 1 syntax).
-- Verified locally via LocalSolution.idr (Idris 2.0.8 equivalent) —
-- see README.md.

%access export
%default total

-- | Implement all these functions
mutual
  evenPlusEven : Even m -> Even n -> Even (m + n)
  evenPlusEven EZero en = en
  evenPlusEven (ESuc om) en = ESuc (oddPlusEven om en)

  oddPlusEven : Odd m -> Even n -> Odd (m + n)
  oddPlusEven (OSuc em) en = OSuc (evenPlusEven em en)

  oddPlusOdd : Odd m -> Odd n -> Even (m + n)
  oddPlusOdd {m = S m} {n = S n} (OSuc em) (OSuc en) =
    -- plus recurses on the first argument, so S m + S n does not
    -- definitionally reduce to S (S (m + n)); bridge with the
    -- canonical lemma from the Prelude.
    rewrite sym (plusSuccRightSucc m n) in ESuc (OSuc (evenPlusEven em en))

  evenPlusOdd : Even m -> Odd n -> Odd (m + n)
  evenPlusOdd EZero on = on
  evenPlusOdd (ESuc om) on = OSuc (oddPlusOdd om on)