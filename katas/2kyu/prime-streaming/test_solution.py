import sys, os
from itertools import islice

sys.path.insert(0, os.path.dirname(__file__))
from solution import primes


def is_prime(n):
    if n < 2:
        return False
    if n % 2 == 0:
        return n == 2
    f = 3
    while f * f <= n:
        if n % f == 0:
            return False
        f += 2
    return True


fails = 0

# first primes, exactly in order
first12 = list(islice(primes(), 12))
if first12 != [2, 3, 5, 7, 11, 13, 17, 19, 23, 29, 31, 37]:
    fails += 1
    print(f"FAIL first 12: {first12}")

# cross-check: first 200 streamed values are prime and strictly increasing
head = list(islice(primes(), 200))
if any(not is_prime(p) for p in head):
    fails += 1
    print("FAIL: non-prime among first 200")
if any(b <= a for a, b in zip(head, head[1:])):
    fails += 1
    print("FAIL: not strictly increasing among first 200")

# known checkpoints: 1000th prime = 7919, 10000th prime = 104729
for count, want in [(1000, 7919), (10000, 104729)]:
    got = list(islice(primes(), count))[-1]
    if got != want:
        fails += 1
        print(f"FAIL {count}th prime = {got}, want {want}")

# independent stream restarts from 2
if next(primes()) != 2:
    fails += 1
    print("FAIL: second stream does not restart at 2")

print(f"fails: {fails}/5")
if fails:
    sys.exit(1)
print("ALL TESTS PASS")
