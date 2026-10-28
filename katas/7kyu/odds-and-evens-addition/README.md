# Odds and Evens: Addition (Idris)

**Kyu:** 7 · **Source:** [Codewars](https://www.codewars.com/kata/odds-and-evens)
(Idris beta, by bredor) — the recursively-defined parity types

```
Even : Nat -> Type     Odd : Nat -> Type
EZero : Even 0         OSuc : Even n -> Odd (S n)
ESuc  : Odd n -> Even (S n)
```

implement `+` at the type level: given witnesses of the parities of `m` and
`n`, return a witness of the parity of `m + n`.

## Solution

Four structural inductions, one per parity combination. The shapes are
forced by the constructors:

```
evenPlusEven EZero        en  = en                  -- 0 + n = n
evenPlusEven (ESuc om)    en  = ESuc (oddPlusEven om en)    -- S m + n = S (m + n)

oddPlusEven  (OSuc em)    en  = OSuc (evenPlusEven em en)

evenPlusOdd  EZero        on  = on
evenPlusOdd  (ESuc om)    on  = OSuc (oddPlusOdd om on)

oddPlusOdd   (OSuc em) (OSuc en) =
  rewrite sym (plusSuccRightSucc m n) in ESuc (OSuc (evenPlusEven em en))
```

**The one non-definitional case is `oddPlusOdd`.** `plus` recurses on the
*first* argument, so `S m + S n` reduces to `S (m + S n)` and stops — it
does not reach `S (S (m + n))`. The witness `ESuc (OSuc (…))` builds
exactly `Even (S (S (m + n)))`, so the two sides are bridged with the
canonical lemma `plusSuccRightSucc m n : S (m + n) = m + S n` (rewritten
`sym`). Every other clause is definitionally equal under `+`.

All four are `total`: every recursive call is on a syntactically smaller
argument.

## Verified

- `idris2 --check` (Idris 2, 0.8.0) passes for `LocalSolution.idr` and
  `test.idr` — the proofs are total and the witness suite type-checks.
  The platform's sample suite (`Specdris`, `pure $ 1===1`) accepts a
  type-checking module, i.e. exactly this gate.
- Codewars runs this kata on **Idris 1.3** (per the stub's `%access
  export` / `%default total` directives and Specdris tests). `solution.idr`
  is therefore written in Idris 1 syntax and is the file to submit;
  `LocalSolution.idr` is the Idris 2 equivalent — proofs identical,
  directives per-declaration (`export total`), plus `import Data.Nat` for
  the lemma (Idris 1 has it in the auto-imported Prelude).
- `test.idr` (Idris 2 only) builds seven concrete witnesses — `Even 2`,
  `Odd 1`, `Even 4`, `Odd 3` — applies the four proofs and asserts the
  represented Nat indexes match the arithmetic sums: 2+4=6, 1+4=5, 1+3=4,
  2+3=5, 0+4=4, 0+3=3, 2+1=3, plus the zero base cases.
- Not yet run: the witness program's execution (sandbox posture here
  blocks running compiled/interpreted code) and the platform submission
  (needs network + the szepnapot Codewars token).

## Files

- `solution.idr` — platform-faithful **Idris 1.3** solution (submit this)
- `LocalSolution.idr` — Idris 2 equivalent of the same proofs
- `Preloaded.idr` — local mirror of the platform's Preloaded parity types
- `test.idr` — local Idris 2 witness suite (7 cases)
- `probe.idr` — scratch probe used to check Idris 2 directive support
  (rejects `%access export`; kept for reference)