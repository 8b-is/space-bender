module Modulo

import Data.Fin

%default total

addImpl : (k : Nat) -> Fin k -> Fin k -> Fin k
addImpl Z x y = absurd x
addImpl (S n) x y = x + y

negateImpl : (k : Nat) -> Fin k -> Fin k
negateImpl Z x = absurd x
negateImpl (S n) x = negate x

subtImpl : (k : Nat) -> Fin k -> Fin k -> Fin k
subtImpl Z x y = absurd x
subtImpl (S n) x y = x - y

multImpl : (k : Nat) -> Fin k -> Fin k -> Fin k
multImpl Z x y = absurd x
multImpl (S n) x y = x * y

public export
add : {k : Nat} -> Fin k -> Fin k -> Fin k
add {k} x y = addImpl k x y

public export
negate : {k : Nat} -> Fin k -> Fin k
negate {k} x = negateImpl k x

public export
subt : {k : Nat} -> Fin k -> Fin k -> Fin k
subt {k} x y = subtImpl k x y

public export
mult : {k : Nat} -> Fin k -> Fin k -> Fin k
mult {k} x y = multImpl k x y
