# Beeramid (5 kyu — Prolog)

- **Codewars Kata**: [Beeramid](https://www.codewars.com/kata/51e04f6b544cf3f6550000c1)
- **ID**: `51e04f6b544cf3f6550000c1`
- **Language**: SWI-Prolog (`solution.pl`)

## Overview

Given a referral `Bonus` and the `Price` of a single beer can, compute the number of **complete** levels $L$ of a square-base pyramid ($1^2 + 2^2 + \dots + L^2$ cans) that can be purchased.

First, the total number of affordable whole cans is:

$$C = \max\!\left(0, \left\lfloor \frac{\text{Bonus}}{\text{Price}} \right\rfloor\right)$$

Level $k$ requires $k^2$ cans, so $L$ complete levels require the $L$-th **square pyramidal number**:

$$P_L = \sum_{k=1}^{L} k^2 = \frac{L(L+1)(2L+1)}{6}$$

---

## Approach 1: Idiomatic Tail-Recursive Accumulator (`beeramid/3`)

In Prolog, loops are expressed as **tail-recursive predicates** where state is threaded through arguments and deterministic branching uses the ISO soft-cut conditional `( Condition -> Then ; Else )`:

```prolog
beeramid(Bonus, Price, Levels) :-
    Cans is max(0, floor(Bonus / Price)),
    beeramid_levels(Cans, 1, Levels).

beeramid_levels(Cans, Level, Levels) :-
    Needed is Level * Level,
    (   Cans >= Needed
    ->  Remaining is Cans - Needed,
        NextLevel is Level + 1,
        beeramid_levels(Remaining, NextLevel, Levels)
    ;   Levels is Level - 1
    ).
```

### Key Prolog Concepts to Absorb

1. **Unification (`=`) vs. Arithmetic Evaluation (`is`)**:
   - In Prolog, `X = 1 + 2` unifies `X` with the *unevaluated compound term* `+(1, 2)`.
   - `X is 1 + 2` evaluates the right-hand arithmetic expression and unifies `X` with `3`.
2. **Strict Term Identity (`==`) in `plunit`**:
   - Codewars tests use `assertion(R == 1)`, which checks strict term identity without type coercion (`1 == 1.0` fails!).
   - Using integer arithmetic (`floor/1`, `-`, `+`) guarantees `Levels` is always bound to an exact integer.
3. **Deterministic `( Cond -> Then ; Else )` & Last-Call Optimization (LCO)**:
   - Because `( Cans >= Needed -> ... ; ... )` commits to the branch before the recursive call `beeramid_levels(Remaining, NextLevel, Levels)` in tail position, SWI-Prolog reuses the stack frame in $O(1)$ space and leaves **zero lingering choicepoints**.

---

## Approach 2: $O(1)$ Cube-Root Sandwich Inequality (`beeramid_o1/3`)

Multiplying the square pyramidal formula by $3$:

$$3 P_n = \frac{n(n+1)(2n+1)}{2} = n^3 + \frac{3}{2}n^2 + \frac{1}{2}n$$

Comparing with consecutive cubes $n^3$ and $(n+1)^3 = n^3 + 3n^2 + 3n + 1$, for every integer $n \ge 1$:

$$n^3 < 3 P_n < (n+1)^3$$

Therefore, if $P_L \le C < P_{L+1}$, then:

$$L^3 < 3 P_L \le 3 C < 3 P_{L+1} < (L+2)^3 \implies L < (3C)^{1/3} < L + 2$$

Thus $K = \lfloor (3C)^{1/3} \rfloor$ is **always** either $L$ or $L + 1$, and a single polynomial check $K(K+1)(2K+1) \le 6C$ gives the exact level in $O(1)$ time:

```prolog
beeramid_o1(Bonus, Price, Levels) :-
    Cans is max(0, floor(Bonus / Price)),
    K is floor((3 * Cans) ** (1 / 3)),
    (   K * (K + 1) * (2 * K + 1) =< 6 * Cans
    ->  Levels = K
    ;   Levels is K - 1
    ).
```

## Running Tests

```bash
swipl -q -g run_tests -t halt katas/5kyu/beeramid/test.pl
# or via space-bender / codewars-cli:
codewars bender test --filter beeramid
```
