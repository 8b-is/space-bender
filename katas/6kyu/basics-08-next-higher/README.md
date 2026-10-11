# Basics 08: Find next higher number with same Bits (λ Calculus)

**Kyu:** 6 · **Source:** [Codewars](https://www.codewars.com/kata/5a6b80cb880385a8f7000089)
(λ Calculus / Beta) · `basics-08-find-next-higher-number-with-same-bits-1-s`

Given an int `1 .. 2^30`, return the next higher number with the same
popcount (Gosper's hack). Examples: `129 → 130`, `127 → 191`, `1 → 2`,
`323423 → 323439`. Config: `numEncoding: BinaryScott`, no purity line
(works under PureLC, Let and LetRec — the solution is a single
self-contained term).

## Solution

**BinaryScott digits** are little-endian Scott-encoded binary:
`n = \ end even odd . ...` with `End = 0`, `Even z = 2z`,
`Odd z = 2z+1`, LSB outermost.

**Algorithm** (LSB-first, counter-free) — write
`x = 0^s 1^k 0 rest` (or `0^s 1^k End` when x is all-ones above s):

```
nextHigher = 1^(k-1) · 0^(s+1) · 1 · rest
           = Odd^(k-1) ( Even^(s+1) ( Odd rest ) )
```

- **phase1 (`g1`)**: skip trailing zeros, accumulating `Even`-wrappers.
  `em` is seeded with one `Even`, so `s` trailing zeros end as `s+1`
  `Even`-wraps — exactly the `0^(s+1)` block (the separator's zero also
  belongs to it).
- **phase2 (`g2`)**: on the first `1`, skip the ones-run accumulating
  `k-1` `Odd`-wrappers (`pend`); on the separating `0` — or `End` for
  the all-ones case — emit `pend (em (O rest))`.
- Recursion is via the **Z combinator** inline; no top-level helpers, no
  direct self-reference, so the one-line term parses and evaluates under
  every purity mode.

## Verified

Real compiler (`@codewars/lambda-calculus` 1.1.2), `ALL PASS` on 87
checks: the 4 kata examples, exhaustive sweep `1..64`, range edges
`2^30 → 2^31` and `1.5·2^30 → 2^31+1`, plus 20 deterministic randoms up
to `2^30` — all against a JS Gosper reference (`(ripple | ones) >>> 0`).
Re-validated identically under `PureLC`, `Let` and `LetRec`. ~1 ms per
call; results never carry leading (most-significant) zeros, so the
compiler's `isPadded` invariant holds.

## Files

- `solution.lc` — the solution
- `test.mjs` — verification harness (runs against the real compiler)
- `package.json` — pins `@codewars/lambda-calculus`
