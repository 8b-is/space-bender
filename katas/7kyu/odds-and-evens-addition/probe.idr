module Solution

import Preloaded

%access export
%default total

mutual
  evenPlusEven : Even m -> Even n -> Even (m + n)
  evenPlusEven EZero en = en
  evenPlusEven (ESuc om) en = ESuc (oddPlusEven om en)

  oddPlusEven : Odd m -> Even n -> Odd (m + n)
  oddPlusEven (OSuc em) en = OSuc (evenPlusEven em en)

  oddPlusOdd : Odd m -> Odd n -> Even (m + n)
  oddPlusOdd (OSuc em) (OSuc en) = ESuc (OSuc (evenPlusEven em en))

  evenPlusOdd : Even m -> Odd n -> Odd (m + n)
  evenPlusOdd EZero on = on
  evenPlusOdd (ESuc om) on = OSuc (oddPlusOdd om on)