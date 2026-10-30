# Google interview (Idris 1.3)

**Kyu:** 7 · **Source:** [Codewars](https://www.codewars.com/kata/5c85201e20f73f08df4216b1) · **ID:** `5c85201e20f73f08df4216b1`
(Idris 1.3 / Agda / Coq / Lean, by `ice1000` — inspired by Max Howell's famous binary tree inversion tweet)

Given `module T`:

```idris
module T

%access export
%default total

data Tree : Type -> Type where
    Leaf : a -> Tree a
    Branch : a -> Tree a -> Tree a -> Tree a

flipTree : Tree a -> Tree a
flipTree (Leaf x) = Leaf x
flipTree (Branch x l r) = Branch x (flipTree r) (flipTree l)
```

Prove in `module P` (`%access export`, `%default total`) that `flipTree` is an involution:

```idris
flipTreeSym : (t : Tree a) -> t = flipTree (flipTree t)
```

## Solution

By structural induction on `t : Tree a`:

1. **Base case (`t = Leaf x`)**:
   `flipTree (flipTree (Leaf x))` reduces definitionally to `Leaf x`, so `Refl : Leaf x = Leaf x` closes the goal immediately.
2. **Inductive step (`t = Branch x l r`)**:
   - One step of `flipTree` swaps `l` and `r`:
     `flipTree (Branch x l r) = Branch x (flipTree r) (flipTree l)`
   - The second step of `flipTree` swaps them back:
     `flipTree (flipTree (Branch x l r)) = Branch x (flipTree (flipTree l)) (flipTree (flipTree r))`
   - Applying the binary congruence lemma `congBranch` to the inductive hypotheses `flipTreeSym l : l = flipTree (flipTree l)` and `flipTreeSym r : r = flipTree (flipTree r)` yields `Branch x l r = Branch x (flipTree (flipTree l)) (flipTree (flipTree r))`.

```idris
module P

import T

%access export
%default total

congBranch : (x : a) -> l1 = l2 -> r1 = r2 -> Branch x l1 r1 = Branch x l2 r2
congBranch _ Refl Refl = Refl

flipTreeSym : (t : Tree a) -> t = flipTree (flipTree t)
flipTreeSym (Leaf x) = Refl
flipTreeSym (Branch x l r) = congBranch x (flipTreeSym l) (flipTreeSym r)
```

*(Equivalent `rewrite` formulation in Idris 1.3: `flipTreeSym (Branch x l r) = rewrite sym (flipTreeSym l) in rewrite sym (flipTreeSym r) in Refl`.)*

## Files

- `solution.idr` — the Idris 1.3 `module P` proof
- `test_solution.py` — structural & constructive identity-type verification suite
- `bluesky-receipt.json` — live 4-post ELI5 educational Bluesky thread receipt ([root post on `@0xp3t3rl.bsky.social`](https://bsky.app/profile/0xp3t3rl.bsky.social/post/3mz37rkidoa2q))

