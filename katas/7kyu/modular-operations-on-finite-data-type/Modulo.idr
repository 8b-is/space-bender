module Modulo

import Data.Fin

%access export
%default total

add : Fin k -> Fin k -> Fin k
add FZ m = m
add (FS n) m = finS (add (weaken n) m)

negate : Fin k -> Fin k
negate x = finS (complement x)

subt : Fin k -> Fin k -> Fin k
subt n m = add n (negate m)

mult : Fin k -> Fin k -> Fin k
mult FZ _ = FZ
mult (FS n) m = add m (mult (weaken n) m)
