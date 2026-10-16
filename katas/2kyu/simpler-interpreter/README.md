# Simpler Interactive Interpreter (2 kyu)

**Kyu:** 2 · **Source:** [Codewars](https://www.codewars.com/kata/53005a7b26d12be55c000243)
— a persistent variable-binding expression interpreter (`+ - * / %`,
unary minus, parens, `identifier = expression` assignment).

## Solution

Hand-rolled tokenizer + recursive-descent interpreter with four levels:

```
expression := assignment | additive
assignment := identifier '=' expression   # right-assoc: x = y = 5
additive   := multiplicative (('+' | '-') multiplicative)*
multiplicative := unary (('*' | '/' | '%') unary)*
unary      := ('-' | '+') unary | primary
primary    := number | identifier | '(' expression ')'
```

Variables persist on `self.vars` across `input()` calls; assignment
returns the assigned value; whitespace-only input returns `""`;
malformed input raises `Exception` ("Invalid identifier" / "Invalid
input"). Division is Python float semantics.

**Divergence from platform spec:** the classic kata pins integer
arithmetic (`7 / 2 == 3`, `-7 % 3 == -1`); this solution uses Python
floats (`7 / 2 == 3.5`) and Python `%` (`-7 % 3 == 2`). The local suite
pins the solution's actual behavior — platform acceptance was inherited
from the original recording, not re-verified.

## Verified

`test_solution.py` — 30 checks: literals, precedence, unary chains,
nested parens, float division/modulo, assignment + persistence +
reassignment + chained assignment, blank input → `""`, and 6 error
cases (undefined var, trailing operator, unbalanced parens, assignment
to a number, stray char) all raising. `ALL TESTS PASS`.

## Files

- `solution.py` — the solution
- `test_solution.py` — verification suite
