import sys, os
sys.path.insert(0, os.path.dirname(__file__))
from solution import calc

def close(a, b, tol=1e-9):
    return abs(a - b) <= tol

cases = [
    # basics
    ("1 + 1", 2), ("8/16", 0.5), ("(2 + 2) * 2", 8),
    ("2 * 3 + (2 * 2) / 2", 8), ("0.5 + 1.5", 2),
    ("3 + 4 * 2 / ( 1 - 5 )", 1),
    # precedence / associativity
    ("14 + 3 * 8 / (3 + 1) * 2", 26), ("1 + 2 - 3", 0),
    ("2 - 3 * 4 / 2", -4), ("100 / 10 / 2", 5), ("2 * 3 * 4", 24),
    # unary minus (factor-level, recursive)
    ("1 - -2", 3), ("-2 * 2", -4), ("2 * -1 + 3", 1),
    ("--2", 2), ("-(4)", -4), ("6 + -(-4)", 10), ("1--1", 2),
    # whitespace + nesting + floats
    ("  ( 2.5 + 1.5 ) * 2  ", 8), ("((2))", 2), ("(1 + 2) * (3 - 1)", 6),
    ("2.5 * 4", 10), ("-0.5 + 1.5", 1),
]
fails = 0
for expr, want in cases:
    got = calc(expr)
    if not close(got, want):
        fails += 1
        print(f"FAIL calc({expr!r}) = {got}, want {want}")
print(f"fails: {fails}/{len(cases)}")
if fails:
    sys.exit(1)
print("ALL TESTS PASS")
