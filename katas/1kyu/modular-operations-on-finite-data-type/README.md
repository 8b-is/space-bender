# Modular operations on Finite data type

**Kyu:** 7 · **Source:** [Codewars](https://www.codewars.com/kata/15496) · **Language:** Idris (Beta) 1.3

## Problem

The `Fin k` type (from `Data.Fin`) describes a bounded natural number in the range `0 <= n < k`. It is defined as:

```idris
data Fin : Nat -> Type where
  FZ : Fin (S k)
  FS : Fin k -> Fin (S k)
```

Using the bounded nature, one can interpret `Fin k` as a type that represents integers modulo `k`. This gives rise to modular arithmetic: modular addition, subtraction, and multiplication.

Implement the functions:

```idris
total add : Fin k -> Fin k -> Fin k
total negate : Fin k -> Fin k
total subt : Fin k -> Fin k -> Fin k
total mult : Fin k -> Fin k -> Fin k
```

Hint: For me, it was easier to provide `negate` and `subt` before `add`.

## Solution

The solution uses structural recursion on the `Fin` type with `finS` (successor with wrap-around), `complement` (finite complement), and `weaken` (bound weakening) from `Data.Fin`.

- `add`: Recurses on the first argument, using `finS` for wrap-around
- `negate`: Uses `finS (complement x)` for additive inverse
- `subt`: Defined as `add n (negate m)`
- `mult`: Recurses on the first argument, using repeated addition

## Files

- `Modulo.idr` — Idris 1.3 implementation with `%access export`, `%default total`
- `test_solution.py` — Structural verification test suite
