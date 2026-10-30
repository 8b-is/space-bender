module P

import T

{-
public export
data Tree : Type -> Type where
  Leaf : a -> Tree a
  Branch : a -> Tree a -> Tree a -> Tree a

public export
flipTree : Tree a -> Tree a
flipTree (Leaf x) = Leaf x
flipTree (Branch x l r) = Branch x (flipTree r) (flipTree l)
-}

%access export
%default total

congBranch : (x : a) -> l1 = l2 -> r1 = r2 -> Branch x l1 r1 = Branch x l2 r2
congBranch _ Refl Refl = Refl

flipTreeSym : (t : Tree a) -> t = flipTree (flipTree t)
flipTreeSym (Leaf x) = Refl
flipTreeSym (Branch x l r) = congBranch x (flipTreeSym l) (flipTreeSym r)
