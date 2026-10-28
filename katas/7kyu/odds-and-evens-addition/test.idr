module Main

import LocalSolution
import Preloaded

-- Local verification harness (Idris 2): builds concrete Even/Odd witnesses,
-- applies the four addition proofs, and checks the represented Nat index
-- against the arithmetic sum.  The platform's own sample test only requires
-- the module to type-check; these go further and evaluate witness cases.
--
-- Pass/fail is encoded in stdout ("ALL PASS" vs "TEST FAILURES ABOVE");
-- the run wrapper asserts on it.  (System.Exit is not in this idris2 base.)

mutual
  indexE : Even n -> Nat
  indexE EZero = 0
  indexE (ESuc o) = S (indexO o)

  indexO : Odd n -> Nat
  indexO (OSuc e) = S (indexE e)

check : String -> Bool -> IO Bool
check label ok =
  if ok then putStrLn ("ok   " ++ label) >> pure True
        else putStrLn ("FAIL " ++ label) >> pure False

e2 : Even 2
e2 = ESuc (OSuc EZero)

e4 : Even 4
e4 = ESuc (OSuc (ESuc (OSuc EZero)))

o1 : Odd 1
o1 = OSuc EZero

o3 : Odd 3
o3 = OSuc (ESuc (OSuc EZero))

main : IO ()
main = do
  r1 <- check "evenPlusEven (Even 2) (Even 4) = Even 6"  (indexE (evenPlusEven e2 e4) == 6)
  r2 <- check "oddPlusEven  (Odd 1)  (Even 4) = Odd 5"   (indexO (oddPlusEven o1 e4)  == 5)
  r3 <- check "oddPlusOdd   (Odd 1)  (Odd 3)  = Even 4"  (indexE (oddPlusOdd o1 o3)   == 4)
  r4 <- check "evenPlusOdd  (Even 2) (Odd 3)  = Odd 5"   (indexO (evenPlusOdd e2 o3)  == 5)
  r5 <- check "evenPlusEven EZero    (Even 4) = Even 4"  (indexE (evenPlusEven EZero e4) == 4)
  r6 <- check "evenPlusOdd  EZero    (Odd 3)  = Odd 3"   (indexO (evenPlusOdd EZero o3)  == 3)
  r7 <- check "evenPlusOdd  (Even 2) (Odd 1)  = Odd 3"   (indexO (evenPlusOdd e2 o1)   == 3)
  if and [r1, r2, r3, r4, r5, r6, r7]
    then putStrLn "ALL PASS"
    else putStrLn "TEST FAILURES ABOVE"