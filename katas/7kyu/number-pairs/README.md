# Number Pairs (λ Calculus)

**Kyu:** 7 · **Source:** Codewars (λ Calculus / Beta)

Compare each pair of elements from two equal-length Church-encoded lists
of Church numerals, and return a new list holding the larger value of each
pair. The solution must export the List interface — `cons`, `nil`,
`foldr` — plus `get-larger-numbers`. Config: `purity: LetRec`,
`numEncoding: Church`.

## Solution

- **Church lists**: `nil = \ c n . n`; `cons` extends the right-fold
  function; a list *is* its fold, so `foldr f z l = l f z`.
- **`tail` via the pred trick**: a Church list cannot expose its tail
  directly, so a state-threading fold yields `pair tail whole` and `fst`
  extracts the sublist (same idea as Church `pred`).
- **`max`**: `leq m n = iszero (monus m n)` with
  `monus m n = n pred m`, then select `(leq m n) n m`.
- **`get-larger-numbers`**: LetRec recursion zips the two lists in
  lockstep, gated by `isnil`. Safe under the compiler's **lazy**
  evaluation (probed empirically — the recursive branch is never forced
  on empty lists).

Verified against the real compiler (`@codewars/lambda-calculus` 1.1.2):
the exact kata example plus edge cases (empty lists, ties, zeros, larger
values), and a deterministic scale check (n=60, values < 100). Comparison
is inherently Ω(max²) per pair in Church numerals — fine at kata test
scale; values in the thousands get slow (seconds), which is a property of
the encoding, not the algorithm.

## Files

- `solution.lc` — the solution
- `test.mjs` — verification harness (runs against the real compiler)
- `package.json` — pins `@codewars/lambda-calculus`
