import sys, os

sys.path.insert(0, os.path.dirname(__file__))
from preloaded import Any, Normal, Or, Str, ZeroOrMore
from solution import parse_regexp

N = Normal
cases = [
    # single nodes
    ("a", N("a")),
    ("3", N("3")),
    (".", Any()),
    # concatenation — flat Str list, no nesting
    ("abc", Str([N("a"), N("b"), N("c")])),
    ("0.5", Str([N("0"), Any(), N("5")])),
    # star quantifier
    ("a*", ZeroOrMore(N("a"))),
    (".*", ZeroOrMore(Any())),
    ("a*b", Str([ZeroOrMore(N("a")), N("b")])),
    ("ab*", Str([N("a"), ZeroOrMore(N("b"))])),
    # parens are transparent (no Group node)
    ("(a)", N("a")),
    ("(ab)", Str([N("a"), N("b")])),
    ("(ab)+", Str([Str([N("a"), N("b")]), N("+")])),  # no OneOrMore: '+' is a literal char, parens keep their Str node
    ("(ab)*", ZeroOrMore(Str([N("a"), N("b")]))),
    # alternation
    ("a|b", Or(N("a"), N("b"))),
    ("(a|b)", Or(N("a"), N("b"))),
    ("(a|b)*", ZeroOrMore(Or(N("a"), N("b")))),
    ("a|b*c", Or(N("a"), Str([ZeroOrMore(N("b")), N("c")]))),
    # mixed moderately complex tree
    ("(ab|c)*d", Str([ZeroOrMore(Or(Str([N("a"), N("b")]), N("c"))), N("d")])),
    ("a.(b|c).d*", Str([N("a"), Any(), Or(N("b"), N("c")), Any(), ZeroOrMore(N("d"))])),
    # invalids -> None (this variant: Or non-associative, single star, balanced parens, no leading/trailing/operator-only pieces)
    ("", None),
    ("(", None),
    (")", None),
    ("a)", None),
    ("(a", None),
    ("*a", None),
    ("a|", None),
    ("|a", None),
    ("a||b", None),
    ("a|b|c", None),
    ("(a|b|c)", None),
    ("a**", None),
]

fails = 0
for src, want in cases:
    got = parse_regexp(src)
    if got != want:
        fails += 1
        print(f"FAIL parse_regexp({src!r}) = {got!r}, want {want!r}")

print(f"fails: {fails}/{len(cases)}")
if fails:
    sys.exit(1)
print("ALL TESTS PASS")
