import sys, os

sys.path.insert(0, os.path.dirname(__file__))
from solution import Interpreter

fails = 0


def check(label, got, want):
    global fails
    if got != want:
        fails += 1
        print(f"FAIL {label}: got {got!r}, want {want!r}")


def check_raises(label, fn, msg_substr=None):
    global fails
    try:
        fn()
    except Exception as e:
        if msg_substr is not None and msg_substr not in str(e):
            fails += 1
            print(f"FAIL {label}: message {str(e)!r} lacks {msg_substr!r}")
        return
    fails += 1
    print(f"FAIL {label}: expected exception, got no raise")


i = Interpreter()

# literals, precedence, parens, unary
check("1 + 1", i.input("1 + 1"), 2)
check("2 * 2", i.input("2 * 2"), 4)
check("1 + 2 * 3", i.input("1 + 2 * 3"), 7)
check("(1 + 2) * 3", i.input("(1 + 2) * 3"), 9)
check("2 - -2", i.input("2 - -2"), 4)
check("-3 * 2", i.input("-3 * 2"), -6)
check("+3", i.input("+3"), 3)
check("2 + + 3", i.input("2 + + 3"), 5)
check("nested parens", i.input("((2 + 3)) * 2"), 10)

# float division + modulo (this solution: float semantics, not integer)
check("7 / 2", i.input("7 / 2"), 3.5)
check("7 % 3", i.input("7 % 3"), 1)
check("-7 % 3", i.input("-7 % 3"), 2)  # Python modulo semantics
check("2.5 * 4", i.input("2.5 * 4"), 10)

# variables: assignment, persistence, reassignment, chained assignment
check("x = 5", i.input("x = 5"), 5)
check("x + 1", i.input("x + 1"), 6)
check("y = x * 2", i.input("y = x * 2"), 10)
check("x + y", i.input("x + y"), 15)
check("x = 6 reassign", i.input("x = 6"), 6)
check("x after reassign", i.input("x"), 6)
check("x = y = 5 chained", i.input("x = y = 5"), 5)
check("underscore ident", i.input("_a = 2"), 2)
check("_a + 1", i.input("_a + 1"), 3)

# whitespace-only input -> ""
check("blank", i.input("   "), "")
check("empty", i.input(""), "")

# errors
check_raises("undefined var", lambda: Interpreter().input("a + 1"), "Invalid identifier")
check_raises("trailing op", lambda: Interpreter().input("2 +"), None)
check_raises("open paren", lambda: Interpreter().input("(2 + 2"), None)
check_raises("extra close", lambda: Interpreter().input("(2 + 2))"), None)
check_raises("assign to number", lambda: Interpreter().input("2 = 3"), None)
check_raises("stray char", lambda: Interpreter().input("2 # 3"), None)

print(f"fails: {fails}/30")
if fails:
    sys.exit(1)
print("ALL TESTS PASS")
