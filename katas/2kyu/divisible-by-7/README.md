# Regular Expression - Check if divisible by 0b111 (7)

**Kyu:** 2 · **Source:** Codewars (Hacker Sakana)

Create a regular expression capable of evaluating binary strings (which
consist of only 1's and 0's) and determining whether the given string
represents a number divisible by 7.

- Empty strings should be rejected.
- Reject strings with any character other than 0 and 1.
- No leading 0's will be tested unless the string exactly denotes 0.

## Solution

Built from a 7-state DFA (states = remainder mod 7, transitions
`r*2+b % 7`), then **state elimination** (remove states 1..6 one at a time,
splicing paths as `A(loop)*B`), leaving a self-loop regex `R` on the accept
state, wrapped as `^(R)+$`. Every concatenation is `(A)(B)` and every
alternative is `(a|b)`, so the parens are guaranteed balanced.

Verified exhaustively against brute-force divisibility for every binary
string up to length 13 (no leading zeros), plus edge cases: empty rejected,
`"0"` accepted, non-binary rejected.

```python
import re

solution = r'^((((((((((1)(0))(0))((((0)(0)|1))(0))*)((((0)(0)|1))(1))|((1)(0))(1)))(((1)((((0)(0)|1))(0))*)((((0)(0)|1))(1)))*)((((1)((((0)(0)|1))(0))*)(((0)(1))(0))|(0)(0)))|((((1)(0))(0))((((0)(0)|1))(0))*)(((0)(1))(0))|((1)(1))(0)))((((0)(((1)((((0)(0)|1))(0))*)((((0)(0)|1))(1)))*)((((1)((((0)(0)|1))(0))*)(((0)(1))(0))|(0)(0)))|1))*)(((0)(((1)((((0)(0)|1))(0))*)((((0)(0)|1))(1)))*)((((1)((((0)(0)|1))(0))*)(((0)(1))(1))|(0)(1))))|(((((((1)(0))(0))((((0)(0)|1))(0))*)((((0)(0)|1))(1))|((1)(0))(1)))(((1)((((0)(0)|1))(0))*)((((0)(0)|1))(1)))*)((((1)((((0)(0)|1))(0))*)(((0)(1))(1))|(0)(1)))|((((1)(0))(0))((((0)(0)|1))(0))*)(((0)(1))(1))|((1)(1))(1)|0)+$'

def seven(s):
    return bool(re.match(solution, s))
```
