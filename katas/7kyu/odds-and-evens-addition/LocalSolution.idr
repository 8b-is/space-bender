module LocalSolution

import Preloaded
import Data.Nat

-- Local Idris 2 (0.8.0) equivalent of solution.idr. The proofs are the same;
-- directives differ because Idris 2 has no %access / %default total:
-- visibility and totality are per-declaration.

mutual
  export
  total
  evenPlusEven : Even m -> Even n -> Even (m + n)
  evenPlusEven EZero en = en
  evenPlusEven (ESuc om) en = ESuc (oddPlusEven om en)

  export
  total
  oddPlusEven : Odd m -> Even n -> Odd (m + n)
  oddPlusEven (OSuc em) en = OSuc (evenPlusEven em en)

  export
  total
  oddPlusOdd : Odd m -> Odd n -> Even (m + n)
  oddPlusOdd {m = S m} {n = S n} (OSuc em) (OSuc en) =
    -- S m + S n does not reduce to S (S (m + n)) definitionally
    -- (plus recurses on the first argument), so bridge the gap with
    -- the canonical lemma.  Requires m, n from a fresh context, so
    -- Data.Nat is imported for the Idris 2 leaner prelude.
    rewrite sym (plusSuccRightSucc m n) in ESuc (OSuc (evenPlusEven em en))

  export
  total
  evenPlusOdd : Even m -> Odd n -> Odd (m + n)
  evenPlusOdd EZero on = on
  evenPlusOdd (ESuc om) on = OSuc (oddPlusOdd om on)