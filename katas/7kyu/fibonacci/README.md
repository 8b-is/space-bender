# Fibonacci (λ Calculus)

**Kyu:** 7 · **Source:** [Codewars](https://www.codewars.com/kata/57a1d5ef7cb1f3db590002af)
(λ Calculus / Beta, by wichu) · classic task: `fib n` returns the n'th
Fibonacci number (`fib 0 = 0`, `fib 1 = 1`). Config: `numEncoding: Scott`,
no purity line — the solution is a single closed term so it runs under
PureLC (the compiler default, which *enforces* closed terms), Let and
LetRec alike.

## Solution

**Scott naturals**: `Zero = \ z u . z`, `Succ v = \ u f . f v`; the
eliminator is the two-case application `n case0 case1`.

**Pair iteration, no branches**: instead of recursing twice per call,
thread the pair `(a, b)`:

```
go n a b  =  a                    if n = Zero
             go (n-1) b (a + b)   if n = Succ _
fib n     =  go n Zero One
```

**Scott addition** (one step of the pair is `a + b`):
`add m t = m t (\ p . \ u f . f (add p t))` — eliminate `m`: zero-case is
`t` itself, succ-case rebuilds one `Succ` over the recursive sum.

Recursion in both `go` and `add` is via the **Z combinator inlined twice**
(no bare `Z` exists in the compiler's prelude). Nothing is defined at top
level except `fib`, and every variable is bound — PureLC-safe.

## Verified

Real compiler (`@codewars/lambda-calculus` 1.1.2), `ALL PASS` on
`fib(0)..fib(25)` against an iterative JS reference, and re-validated
identically under `PureLC`, `Let` and `LetRec`.

Cost is inherently Θ(fib(n)): the Scott result is a unary chain that
`toInt` must walk, so `fib(25) = 75025` already takes seconds and larger
inputs exceed any plausible timeout for *any* solution in this
interpreter — the kata cannot reasonably test beyond this range.

## Files

- `solution.lc` — the solution
- `test.mjs` — verification harness (runs against the real compiler)
- `package.json` — pins `@codewars/lambda-calculus`
