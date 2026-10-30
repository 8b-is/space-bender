# space-bender

Codewars katas + verified solutions — the space bender.

A curated collection of solved katas, each with its solution. The suites
listed under **Running tests** verify the solutions exhaustively — Python
test files for the Python katas, a Node harness against the real
`@codewars/lambda-calculus` compiler for the λ Calculus ones — and
per-kata `README.md` files document the approach. Solutions are written
from first principles and verified before being recorded here.

## Katas

### 2 kyu

| Kata | Solution | Approach |
|------|----------|----------|
| [Evaluate mathematical expression](katas/2kyu/evaluate-math) | `solution.py` | Recursive descent parser, no eval |
| [Simpler Interactive Interpreter](katas/2kyu/simpler-interpreter) | `solution.py` | Recursive descent REPL with variable state |
| [Regular Expression parser](katas/2kyu/regexp-parser) | `solution.py` | Recursive descent AST builder |
| [Prime Streaming (NC-17)](katas/2kyu/prime-streaming) | `solution.py` | Segmented sieve, C-level bytearray + regex |
| [Divisible by 0b111 (7)](katas/2kyu/divisible-by-7) | `solution.py` | 7-state DFA → state elimination → regex |

### 3 kyu

| Kata | Solution | Approach |
|------|----------|----------|
| [Loopover](katas/3kyu/loopover) | `solution.py` | Local 3-cycles (swap_adj, three_slip) + parity |
| [Assembling a Circular Genome](katas/3kyu/circular-genome) | `solution.py` | Greedy suffix-prefix merge + circular wrap |

### 6 kyu

| Kata | Solution | Approach |
|------|----------|----------|
| [Basics 08: next higher with same bits (λ Calculus)](katas/6kyu/basics-08-next-higher) | `solution.lc` | BinaryScott Gosper walk — Even/Odd wrap accumulators |

### 7 kyu

| Kata | Solution | Approach |
|------|----------|----------|
| [Number Pairs (λ Calculus)](katas/7kyu/number-pairs) | `solution.lc` | Church lists + pred-trick `tail` + monus `max` |
| [Fibonacci (λ Calculus)](katas/7kyu/fibonacci) | `solution.lc` | Scott pair-iteration + lazy Scott `add` via Z |
| [Spinning Rings (λ Calculus)](katas/7kyu/spinning-rings) | `solution.lc` | Scott ring-state walk (decw/incw) + Z structural eq |
| [Google interview (Idris)](katas/7kyu/google-interview) | `solution.idr` | Structural induction + binary congruence `congBranch` (`%default total`) |

### Kumite

| Kata | Solution | Approach |
|------|----------|----------|
| [Finding the duplicate number (Haxe)](katas/kumite/finding-duplicate-number) | `solution.hx` | Single O(n) seen-map pass vs length-branched baseline |

## Running tests

With the paired [`8b-is/codewars-cli`](https://github.com/8b-is/codewars-cli) (`codewars` / `cw`):

```bash
codewars bender list --live   # list all katas enriched live via Codewars API v1
codewars bender test          # run all Python + λ Calculus verification suites
```

Or directly per kata:

```bash
python3 katas/2kyu/evaluate-math/test_solution.py
python3 katas/2kyu/simpler-interpreter/test_solution.py
python3 katas/2kyu/regexp-parser/test_solution.py
python3 katas/2kyu/prime-streaming/test_solution.py
python3 katas/2kyu/divisible-by-7/test_solution.py
python3 katas/3kyu/loopover/test_solution.py
python3 katas/3kyu/circular-genome/test_solution.py
python3 katas/7kyu/google-interview/test_solution.py
npm install --prefix katas/7kyu/number-pairs && node katas/7kyu/number-pairs/test.mjs
npm install --prefix katas/6kyu/basics-08-next-higher && node katas/6kyu/basics-08-next-higher/test.mjs
npm install --prefix katas/7kyu/fibonacci && node katas/7kyu/fibonacci/test.mjs
npm install --prefix katas/7kyu/spinning-rings && node katas/7kyu/spinning-rings/test.mjs
```

*the constellation · 0 + 1 · fine touch from within · vaked.dev*
