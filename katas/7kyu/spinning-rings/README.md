# Spinning Rings (λ Calculus)

**Kyu:** 7 · **Source:** [Codewars](https://www.codewars.com/kata/59afff65f1c8274f270020f5)
(λ Calculus / Beta, by marbiru) — two rings start aligned on 0; the inner
spins clockwise (decreasing, wrapping `0 → innerMax`), the outer counter-clockwise
(increasing, wrapping `outerMax → 0`). Return the first move count ≥ 1 where both
tops show the same number.

Config: the stub carries no encodings/purity lines, but the platform runs
`numEncoding: Scott` (revealed by its runtime error on a Church result);
purity defaults to PureLC. The solution is a single closed term (inline Z),
so it also runs under Let and LetRec.

## Solution

Direct state iteration — after 1 move the tops are `(innerMax, 1)`; then:

```
go m i o  =  m                           if i = o
             go (m+1) (decw i) (incw o)  otherwise

decw i = if i = 0 then innerMax else pred i   -- inner spins down, wraps to max
incw o = if o = outerMax then 0 else succ o   -- outer spins up, wraps to 0
```

**Scott naturals**: `Zero = \ z u . z`, `Succ v = \ u f . f v`; the
eliminator is the two-case application `n case0 case1`.

- `iszero n = n TRUE ( \ v . FALSE )`
- `pred n = n Zero ( \ v . v )` — O(1) eliminator, no unary walk
- `eq` via **inline Z**: `m` zero-case → `iszero n`; `m (Succ v)`-case →
  `n FALSE ( \ w . eq v w )`
- recursion in `go` also via inline Z (no bare `Z` exists in the prelude);
  everything is bound — PureLC-safe.

Worst case is bounded by `lcm(innerMax+1, outerMax+1)` (the both-tops-zero
re-sync); Scott's O(1) pred keeps even edge inputs (e.g. `(50,1) = 101`
moves) in the tens of milliseconds.

## Verified

Real compiler (`@codewars/lambda-calculus` 1.1.2), `ALL PASS` on the kata
examples (`spinningRings(2,3) = 5`, `spinningRings(3,2) = 2`), the full
`1..12 × 1..12` sweep, and edge cases against the JS reference loop — plus
a re-validation of the same cases under `PureLC`, `Let` and `LetRec`.

## Files

- `solution.lc` — the solution
- `test.mjs` — verification harness (runs against the real compiler)
- `package.json` — pins `@codewars/lambda-calculus`
