# space-bender

Codewars katas + verified solutions — the space bender.

A curated collection of solved katas, each with its solution. The suites
listed under **Running tests** verify the solutions exhaustively — Python
test files for the Python katas, a Node harness against the real
`@codewars/lambda-calculus` compiler for the λ Calculus ones — and
per-kata `README.md` files document the approach (newer katas ship one
by default). Solutions are written from first principles and verified
before being recorded here.

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

### Kumite

| Kata | Solution | Approach |
|------|----------|----------|
| [Finding the duplicate number (Haxe)](katas/kumite/finding-duplicate-number) | `solution.hx` | Single O(n) seen-map pass vs length-branched baseline |

## Running tests

```bash
python3 katas/2kyu/divisible-by-7/test_solution.py
python3 katas/3kyu/loopover/test_solution.py
python3 katas/3kyu/circular-genome/test_solution.py
npm install --prefix katas/7kyu/number-pairs && node katas/7kyu/number-pairs/test.mjs
npm install --prefix katas/6kyu/basics-08-next-higher && node katas/6kyu/basics-08-next-higher/test.mjs
npm install --prefix katas/7kyu/fibonacci && node katas/7kyu/fibonacci/test.mjs
npm install --prefix katas/7kyu/spinning-rings && node katas/7kyu/spinning-rings/test.mjs
```

*the constellation · 0 + 1 · fine touch from within · vaked.dev*
