# NegaBinary (2 kyu · λ-Calculus)

- **Codewars Kata**: [NegaBinary](https://www.codewars.com/kata/68afa8133e3f243480fed90a) (`68afa8133e3f243480fed90a`)
- **Language**: Lambda Calculus (`purity: "LetRec"`, `verbosity: "Calm"`, `enforceBinaryScottInvariant: true`)
- **Encoding**: Scott-encoded, Little-Endian, sentinel-terminated base $-2$ integers (`Zero = 0`, `Even x = -2x`, `Odd x = 1 - 2x`)

## Key Ideas

1. **Canonical Invariant (`mkE`)**:
   Every non-zero `NegaBinary` number has `Odd` (`O`) as its most significant bit. Constructing an even bit uses `mkE = \ x . x Zero (\ _ . E x) (\ _ . E x)` so `E Zero` collapses to `Zero`.
2. **Two-Step Sign-Flip Unrolling (Single-Function `LetRec`)**:
   In base $-2$, every bit step multiplies by $-2$ and flips the sign. Thus:
   - `pred` transitions to `succ` in 1 step (`pred (E x) = O (succ x)`, `pred (O x) = mkE x`).
   - `lt0` transitions to `gt0` in 1 step (`lt0 = \ n . n False gt0 gt0`).
   - `sneg` ($1 - x$) transitions to `neg` in 1 step, giving a ripple-free single-pass $O(\log n)$ negation and 1-line floor halving `hlf = \ n . n Zero neg neg`.
   - `fbsn` and `tbsNeg` transition to `fbs` and `tbsPos` in 1 step, giving $O(\log n)$ conversions between `NegaBinary` and `BinaryScott`.
3. **Unsigned `BinaryScott` Division & Euclidean `gcd`/`lcm`**:
   Floored signed `div` and `mod` reduce via `abs-bs` to unsigned shift-and-subtract long division `divmod-bs` on `BinaryScott` and adjust quotient/remainder when `xor (lt0 m) (lt0 n)` holds.
4. **Deferred Error Thunks (`\ _ . ()`)**:
   Guarded operations (`div`, `mod`, `pow`, `times`, `to-binary-scott`) wrap the undefined term `()` inside a lambda branch `(\ _ . ())` applied to `Zero` so `@codewars/lambda-calculus` only evaluates `()` when the error branch is selected.
