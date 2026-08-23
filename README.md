# space-bender

Codewars katas + verified solutions — the space bender.

A curated collection of solved katas, each with a `solution.py`, a
`README.md` explaining the approach, and a `test_solution.py` that verifies
the solution exhaustively. Solutions are written from first principles and
verified locally before being recorded here.

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

## Running tests

```bash
python3 katas/2kyu/divisible-by-7/test_solution.py
python3 katas/3kyu/loopover/test_solution.py
```

*the constellation · 0 + 1 · fine touch from within · vaked.dev*
