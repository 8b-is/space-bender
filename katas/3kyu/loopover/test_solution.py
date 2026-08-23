import sys
import random

sys.path.insert(0, ".")
from solution import loopover, change


def random_board(h, w, nmoves=40):
    solved = [[f"{r},{c}" for c in range(w)] for r in range(h)]
    b = [list(r) for r in solved]
    for _ in range(nmoves):
        d = random.choice("RLUD")
        i = random.randrange(h if d in "RL" else w)
        b = change(b, [f"{d}{i}"])
    return b, solved


# kata example
mixed = [list("DEABC"), list("FGHIJ"), list("KLMNO"), list("PQRST"), list("UVWXY")]
solved = [list("ABCDE"), list("FGHIJ"), list("KLMNO"), list("PQRST"), list("UVWXY")]
moves = loopover(mixed, solved)
assert change(mixed, moves) == solved, "kata example must solve"
assert loopover(solved, solved) == [], "already-solved returns []"

# exhaustive over sizes
random.seed(37)
fails = 0
total = 0
for trial in range(30):
    for (h, w) in [
        (2, 2), (2, 3), (3, 3), (3, 4), (4, 4), (4, 5), (5, 5),
        (2, 5), (3, 5), (4, 3), (1, 3), (3, 1), (1, 5), (5, 1),
        (6, 4), (4, 6), (7, 3),
    ]:
        mixed, solved = random_board(h, w, 40)
        total += 1
        moves = loopover(mixed, solved)
        if moves is None or change(mixed, moves) != solved:
            fails += 1
            print("FAIL", h, w)

# unsolvable detection: 3x3 with a single adjacent swap (odd permutation)
mixed2 = [list("BAC"), list("DEF"), list("GHI")]
solved2 = [list("ABC"), list("DEF"), list("GHI")]
assert loopover(mixed2, solved2) is None, "odd parity 3x3 is unsolvable"

print(f"fails: {fails}/{total}")
print("ALL TESTS PASS" if fails == 0 else "FAILED")
