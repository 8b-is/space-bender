# space-bender

Codewars katas + verified solutions — the space bender.

A curated collection of solved katas, each with its solution, a
`README.md` explaining the approach, and tests that verify the solution
exhaustively (Python suites for the Python katas, a Node harness against
the real `@codewars/lambda-calculus` compiler for the λ Calculus ones).
Solutions are written from first principles and verified locally before
being recorded here.

## Katas

### 2 kyu

| Kata | Solution | Approach |
|------|----------|----------|
| [Evaluate mathematical expression](katas/2kyu/evaluate-math) | `calc.py` | Recursive descent parser, no eval |
| [Simpler Interactive Interpreter](katas/2kyu/simpler-interpreter) | `interpreter.py` | Recursive descent REPL with variable state |
| [Regular Expression parser](katas/2kyu/regexp-parser) | `regexp.py` | Recursive descent AST builder |
| [Prime Streaming (NC-17)](katas/2kyu/prime-streaming) | `primes.py` | Segmented sieve, C-level bytearray + regex |
| [Divisible by 0b111 (7)](katas/2kyu/divisible-by-7) | `solution.py` | 7-state DFA → state elimination → regex |

### 3 kyu

| Kata | Solution | Approach |
|------|----------|----------|
| [Loopover](katas/3kyu/loopover) | `solution.py` | Local 3-cycles (swap_adj, three_slip) + parity |

### 7 kyu

| Kata | Solution | Approach |
|------|----------|----------|
| [Number Pairs (λ Calculus)](katas/7kyu/number-pairs) | `solution.lc` | Church lists + pred-trick `tail` + monus `max` |

## Running tests

```bash
python3 katas/2kyu/divisible-by-7/test_solution.py
python3 katas/3kyu/loopover/test_solution.py
npm install --prefix katas/7kyu/number-pairs && node katas/7kyu/number-pairs/test.mjs
```

*the constellation · 0 + 1 · fine touch from within · vaked.dev*
