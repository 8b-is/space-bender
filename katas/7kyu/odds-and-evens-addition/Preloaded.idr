module Preloaded

-- Local mirror of the Codewars kata's Preloaded module, adapted to Idris 2
-- syntax (the platform runs Idris 1.3: %access / %default total directives
-- are handled by the compiler there; Idris 2 wants per-declaration
-- visibility and a mutual block for the cross-referencing types).

mutual
  public export
  data Even : Nat -> Type where
    EZero : Even 0
    ESuc  : Odd n -> Even (S n)

  public export
  data Odd : Nat -> Type where
    OSuc : Even n -> Odd (S n)