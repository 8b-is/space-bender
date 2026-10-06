import re
import sys

sys.path.insert(0, ".")
from solution import solution, seven

pattern = re.compile(solution)

def div7(s):
    return int(s, 2) % 7 == 0

# exhaustive: all binary strings up to length 13 (no leading zeros)
ok = True
for n in range(1, 14):
    for i in range(1 << n):
        s = bin(i)[2:].zfill(n)
        if len(s) > 1 and s[0] == "0":
            continue
        m = bool(pattern.match(s))
        d = div7(s)
        if m != d:
            ok = False
            print("MISMATCH", s, m, d)

# edge cases
assert not pattern.match(""), "empty should be rejected"
assert pattern.match("0"), "'0' should match"
assert pattern.match("111"), "'111' (7) should match"
assert not pattern.match("1001"), "'1001' (9) should not match"
assert not pattern.match("2"), "non-binary rejected"
assert not pattern.match("10a"), "non-binary rejected"


# Python's $ anchor also matches before a trailing newline; require the whole input.
for invalid in ("0\n", "111\n", "111\r\n", "111\t", " 111", "111 "):
    assert not pattern.match(invalid), repr(invalid)
    assert not seven(invalid), repr(invalid)
assert ok, "exhaustive divisibility comparison failed"

print("ALL TESTS PASS")
