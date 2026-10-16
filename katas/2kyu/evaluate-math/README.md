# Evaluate Mathematical Expression (2 kyu)

**Kyu:** 2 · **Source:** [Codewars](https://www.codewars.com/kata/52a78825cdfc2cfc87000005)
— parse an arithmetic expression string (`+ - * /`, unary minus, nested
parens, decimals, arbitrary whitespace) and evaluate it. `eval`/`exec`
forbidden.

## Solution

Hand-rolled **recursive descent parser**, tokenizer + four grammar levels:

```
expression := term (('+' | '-') term)*
term       := factor (('*' | '/') factor)*
factor     := '-' factor | primary      # unary minus, recursive: ---2 ok
primary    := number | '(' expression ')'
```

Precedence falls out of the layering (`term` above `expression`, etc.),
all levels left-associative, division is Python float division. The
tokenizer tolerates the kata's whitespace rules; unary minus is a
`factor`, so `1--1`, `-(4)` and `6 + -(-4)` all parse naturally.

## Verified

`test_solution.py` — 23 cases: basics, precedence/associativity chains
(`14 + 3 * 8 / (3 + 1) * 2` → 26), unary-minus forms straight from the
kata description, nested parens, decimals. `ALL TESTS PASS`.

Note: the kata's sample-test page has long carried the typo
`"2 * 3 + (2 * 2) / 2" → 7`; the correct value under the documented
semantics is **8** (`6 + 4/2`), which is what the suite pins.

## Files

- `solution.py` — the solution
- `test_solution.py` — verification suite
