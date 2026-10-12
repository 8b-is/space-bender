# Spinning Rings (λ Calculus)

**Kyu:** 7 · **Source:** [Codewars](https://www.codewars.com/kata/59afff65f1c8274f270020f5)
(λ Calculus / Beta, by marbiru) — two rings start aligned on 0; the inner
spins clockwise (decreasing, wrapping `0 → innerMax`), the outer counter-clockwise
(increasing, wrapping `outerMax → 0`). Return the first move count ≥ 1 where both
tops show the same number. Config: bare stub, no encodings/purity lines →
platform defaults `Church` + `PureLC`; the solution is a single closed term
(inline Z), so it also runs under Let and LetRec.

## Solution

Direct state iteration — after 1 move the tops are `(innerMax, 1)`; then:

```
go m i o  =  m                        if i = o
             go (m+1) (decw i) (incw o)   otherwise

decw i = if i = 0 then innerMax else i - 1   -- inner spins down, wraps to max
incw o = if o = outerMax then 0 else o + 1   -- outer spins up, wraps to 0
```

Church helpers: `iszero n = n (K false) true`, predecessor via the standard
pair-walk `n (\g k. k (g f)) (\k. x) (\k. k)`, monus `m ⊖ n = n pred m`,
equality as both moni zero. Recursion via the **Z combinator inlined** (no
bare `Z` in the prelude); everything is bound — PureLC-safe.

Worst case is bounded by `lcm(innerMax+1, outerMax+1)` (the both-tops-zero
re-sync), so the unary walk grows with ring sizes — fine for the kata's
modest test inputs, though values near 50 already cost seconds.

## Verified

Real compiler (`@codewars/lambda-calculus` 1.1.2), `ALL PASS` on the kata
examples (`spinningRings(2,3) = 5`, `spinningRings(3,2) = 2`), the full
`1..12 × 1..12` sweep, and edge cases against the JS reference loop — plus
a re-validation of the same cases under `PureLC`, `Let` and `LetRec`.

## Files

- `solution.lc` — the solution
- `test.mjs` — verification harness (runs against the real compiler)
- `package.json` — pins `@codewars/lambda-calculus`
