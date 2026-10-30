# space-bender

Codewars katas + verified solutions — the space bender.

A curated collection of solved katas, each with its solution. The suites
listed under **Running tests** verify the solutions exhaustively — Python
test files for the Python katas, a Node harness against the real
`@codewars/lambda-calculus` compiler for the λ Calculus ones — and
per-kata `README.md` files document the approach. Solutions are written
from first principles and verified before being recorded here.

## Katas

### 1 kyu

| Kata | Solution | Approach |
|------|----------|----------|
| [Express number as sum of four squares (Rust)](katas/1kyu/express-number-as-sum-of-four-squares) | `solution.rs` | Double-sqrt cascade ($1024\text{b} \to 513\text{b} \to 258\text{b}$) + stack `U320` CIOS Montgomery + Cornacchia (~7.2 ms) |
| [Game of Life in Reverse (Factor)](katas/1kyu/game-of-life-in-reverse) | `solution.factor` | Interval neighbor-bound pruning + $(W+1)$-cell 4-bit sliding frontier profile DP |

### 2 kyu

| Kata | Solution | Approach |
|------|----------|----------|
| [Evaluate mathematical expression](katas/2kyu/evaluate-math) | `solution.py` | Recursive descent parser, no eval |
| [Simpler Interactive Interpreter](katas/2kyu/simpler-interpreter) | `solution.py` | Recursive descent REPL with variable state |
| [Regular Expression parser](katas/2kyu/regexp-parser) | `solution.py` | Recursive descent AST builder |
| [Prime Streaming (NC-17)](katas/2kyu/prime-streaming) | `solution.py` | Segmented sieve, C-level bytearray + regex |
| [Divisible by 0b111 (7)](katas/2kyu/divisible-by-7) | `solution.py` | 7-state DFA → state elimination → regex |
| [Church Numerals - Prefix is Overrated (All Operations)](katas/2kyu/church-infix-all-ops) | `solution.lc` | Triple-role `d = \p. p A` + unified `U_x` continuation dispatch |
| [NegaBinary (λ Calculus)](katas/2kyu/negabinary) | `solution.lc` | Base $-2$ Scott encoding + 1-step sign-flip unrolling + BinaryScott `divmod` (~0.73s) |

### 3 kyu

| Kata | Solution | Approach |
|------|----------|----------|
| [Loopover](katas/3kyu/loopover) | `solution.py` | Local 3-cycles (swap_adj, three_slip) + parity |
| [Assembling a Circular Genome](katas/3kyu/circular-genome) | `solution.py` | Greedy suffix-prefix merge + circular wrap |

### 4 kyu

| Kata | Solution | Approach |
|------|----------|----------|
| [Hamming Numbers (NASM)](katas/4kyu/hamming-numbers) | `solution.asm` | 3-pointer DP in `.bss` (`cmovb` + `lea *3/*5`) + 6-insn $O(1)$ lookup |

### 6 kyu

| Kata | Solution | Approach |
|------|----------|----------|
| [Basics 08: next higher with same bits (λ Calculus)](katas/6kyu/basics-08-next-higher) | `solution.lc` | BinaryScott Gosper walk — Even/Odd wrap accumulators |
| [A+A=B+B so A=B? Prove it! (Coq)](katas/6kyu/a-plus-a-equals-b-plus-b) | `solution.v` | Double structural induction + `add_succ_r` + `inversion` (`Closed under the global context`) |
| [Program Verification #2: Fibonacci numbers (Coq)](katas/6kyu/fibonacci-verification) | `solution.v` | Generalized window invariant `fib_aux (fib k) (fib (S k)) n = fib (n + k)` |

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
codewars bender list --live          # list all katas enriched live via Codewars API v1
codewars bender test                 # run all Python + λ Calculus + Idris verification suites
codewars bender eli5 <slug>          # publish a 4-post ELI5 educational Bluesky thread with GitHub links
```

Or directly per kata:

```bash
python3 katas/1kyu/express-number-as-sum-of-four-squares/test_solution.py
python3 katas/2kyu/evaluate-math/test_solution.py
python3 katas/2kyu/simpler-interpreter/test_solution.py
python3 katas/2kyu/regexp-parser/test_solution.py
python3 katas/2kyu/prime-streaming/test_solution.py
python3 katas/2kyu/divisible-by-7/test_solution.py
python3 katas/3kyu/loopover/test_solution.py
python3 katas/3kyu/circular-genome/test_solution.py
python3 katas/4kyu/hamming-numbers/test_solution.py
python3 katas/6kyu/a-plus-a-equals-b-plus-b/test_solution.py
python3 katas/6kyu/fibonacci-verification/test_solution.py
python3 katas/7kyu/google-interview/test_solution.py
npm install --prefix katas/2kyu/church-infix-all-ops && node katas/2kyu/church-infix-all-ops/test.mjs
npm install --prefix katas/7kyu/number-pairs && node katas/7kyu/number-pairs/test.mjs
npm install --prefix katas/6kyu/basics-08-next-higher && node katas/6kyu/basics-08-next-higher/test.mjs
npm install --prefix katas/7kyu/fibonacci && node katas/7kyu/fibonacci/test.mjs
npm install --prefix katas/7kyu/spinning-rings && node katas/7kyu/spinning-rings/test.mjs
```

*the constellation · 0 + 1 · fine touch from within · vaked.dev*
