# Regular Expression Parser (2 kyu)

**Kyu:** 2 · **Source:** [Codewars](https://www.codewars.com/kata/5470c635304c127cad000f0d)
— parse a restricted regular-expression grammar into a preloaded AST
(`Normal`/`Any`/`ZeroOrMore`/`Or`/`Str`), or return `None` on invalid input.

## Solution

Recursive-descent parser over a token list, three grammar levels:

```
expr     := sequence ('|' sequence)?   # Or is non-associative — 'a|b|c' invalid
sequence := (star)*                    # concatenation → flat Str list
star     := atom '*'?                  # single '*' only — '**' invalid
atom     := char | '.' | '(' expr ')'  # no Group node — parens transparent
```

No `OneOrMore`/`Optional`/`Group`/`Begin`/`End` in this variant's
preloaded set: `'+'` is a literal `Normal`, parens are stripped after
parsing the inner expr, `'^'`/`'$'` are plain literals. Errors at any
level propagate `None` upward. Concatenation collects a **flat** list
(`"abc"` → `Str([a, b, c])`, not nested), but a paren group that isn't
the sole sequence element keeps its own `Str` node
(`"(ab)+"` → `Str([Str([a, b]), Normal("+")])`).

## Verified

`test_solution.py` — 31 cases via a local `preloaded.py` AST shim:
single chars, `.`, flat concatenation, star, transparent parens, `Or`
trees, moderately complex `(ab|c)*d`, and 12 invalid inputs
(`""`, unbalanced parens, leading `*`/`|`, `a|b|c`, `a**`, …) all
returning `None`. `ALL TESTS PASS`.

## Files

- `solution.py` — the solution
- `preloaded.py` — local AST shim (platform injects this)
- `test_solution.py` — verification suite
