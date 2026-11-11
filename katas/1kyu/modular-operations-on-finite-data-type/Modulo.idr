module Modulo

import Data.Fin

%access export
%default total

add : Fin k -> Fin k -> Fin k
add FZ m = m
add (FS n) m = case add (weaken n) m of
                 FZ => FZ
                 FS x => FS x

negate : Fin k -> Fin k
negate FZ = FZ
negate (FS n) = FS (negate n)

subt : Fin k -> Fin k -> Fin k
subt n m = add n (negate m)

mult : Fin k -> Fin k -> Fin k
mult FZ _ = FZ
mult (FS n) m = add m (mult n m)
