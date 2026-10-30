# Church Numerals - Prefix is Overrated (All Operations) (λ Calculus)

**Kyu:** 2 · **Source:** [Codewars](https://www.codewars.com/kata/6246448922c354000f0efbb8) · **ID:** `6246448922c354000f0efbb8`
(λ Calculus, by `monadius` — continuation of `@JohanWiltink`'s *Church Numerals - Prefix is Overrated*)

Implement all 6 basic arithmetic operations on Church numerals (`add`, `sub`, `mul`, `div`, `mod`, `pow`) using **12 single-letter combinators** (`a`, `b`, `d`, `i`, `l`, `m`, `o`, `p`, `s`, `u`, `v`, `w`) applied in **infix** position (`Purity: Let`, `Numbers: Church`):

```lambdacalc
2  a d d  3 -> 5
5  s u b  4 -> 1
3  m u l  4 -> 12
5  d i v  2 -> 2
7  m o d  4 -> 3
2  p o w  3 -> 8
0  p o w  0 -> 1
```

## Solution

Since application in λ-calculus is left-associative, `x c1 c2 c3 y` parses as:

$$(((x\ c_1)\ c_2)\ c_3)\ y = (c_1^x\ c_2)\ c_3\ y$$

### 1. Position Partition of the 12 Combinators

| Operation | `c1` (step of `x`) | `c2` (base at `x=0`) | `c3` (dispatch) |
|-----------|--------------------|----------------------|-----------------|
| `a d d` | `a` | `d` | `d` |
| `s u b` | `s` | `u` | `b` |
| `m u l` | `m` | `u` | `l` |
| `d i v` | `d` | `i` | `v` |
| `m o d` | `m` | `o` | `d` |
| `p o w` | `p` | `o` | `w` |

Every letter except **`d`** occupies a single structural role:
- Pure `c1` (step): `a`, `s`, `m`, `p`
- Pure `c2` (base): `u`, `i`, `o`
- Pure `c3` (dispatch): `b`, `l`, `v`, `w`
- **Triple-role `d`**: appears as `c1` in `d i v`, as `c2` and `c3` in `a d d`, and as `c3` in `m o d`.

### 2. Resolving the Triple-Role of `d`

We define:

```lambdacalc
K5_3  = \ x1 x2 x3 x4 x5 . x3
B_GEN = \ self x1 x2 k u1 . u1 (self self) (SUCC k)
B     = B_GEN B_GEN
A     = \ x y w . x K5_3 (y w) y w
d     = \ p . p A
```

1. **Base case of `a d d` (`0 a d d y = d d y`)**:
   - `d d y w` reduces to `A A y w` $\to_\beta$ `(A K5_3 (y w) y) w` $\to_\beta$ `K5_3 K5_3 (y w y) (y w) y w` $\to_\beta$ `y w`.
   - By $\eta$-equivalence, `d d y = y = 0 + y`.
   - For $x \ge 1$, `a = \ p d2 y . SUCC (p d2 y)` wraps `SUCC` $x$ times around `d d y`, yielding `x + y`.
2. **Step of `d i v` (`(x d i) v y`)**:
   - With `i = \ u1 . u1 B ZERO`, each application of `d` maps state `S_k = \ u1 . u1 B k` to `S_k A = A B k = \ u1 . B K5_3 (k u1) k u1 = \ u1 . u1 B (SUCC k) = S_{k+1}`.
   - After $x$ steps, `S_x v y = v B x y = DIV x y` where `v = \ _ x y . DIV x y`.
3. **Dispatch of `m o d`, `s u b`, `m u l`, `p o w`**:
   - For `u = o = \ c3 . c3 (\ _ . MOD) ZERO` and `s = m = p = \ ustate c3 . c3 (\ _ . MOD) (SUCC (ustate (\ _ x . x)))`, the state after $x$ steps is `U_x = \ c3 . c3 (\ _ . MOD) x`.
   - When `c3 = d` (`x m o d y`), `U_x d y = d (\ _ . MOD) x y = ((\ _ . MOD) A) x y = MOD x y`.
   - When `c3` is `b`, `l`, or `w`, it ignores the first argument and applies `SUB`, `MUL`, or `POW` to `x` and `y`.

## Files

- `solution.lc` — the 12 infix Church combinators (`Purity: Let`, `Numbers: Church`)
- `test.mjs` — verification suite against `@codewars/lambda-calculus` (626 test cases)
- `package.json` — pins `@codewars/lambda-calculus`
- `bluesky-receipt.json` — published 4-post ELI5 educational Bluesky thread ([Root: `3mz3gjsx4x622`](https://bsky.app/profile/0xp3t3rl.bsky.social/post/3mz3gjsx4x622))
