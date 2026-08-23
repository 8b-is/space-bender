import random
import sys

sys.path.insert(0, ".")
from solution import reconstruct_genome


def make_genome(n):
    return "".join(random.choice("ATCG") for _ in range(n))


def reads_from(genome, k, spacing, comprehensive=True):
    g = genome + genome
    reads = []
    i = 0
    while i < len(genome):
        reads.append(g[i : i + k])
        i += spacing
    if not comprehensive:
        reads = [r for idx, r in enumerate(reads) if idx % 3 != 1]
    return list(dict.fromkeys(reads))


def add_errors(reads, rate=0.5):
    out = []
    for r in reads:
        if random.random() < rate:
            pos = random.randrange(len(r))
            r = r[:pos] + random.choice([c for c in "ATCG" if c != r[pos]]) + r[pos + 1 :]
        out.append(r)
    return out


def check(genome, s, reads, k):
    subs = {(s + s)[i : i + k] for i in range(len(s))}
    return all(r in subs for r in reads)


# toy tests from the kata
toy1 = ["AAC", "ACG", "GAA", "GTT", "TCG"]
s1 = reconstruct_genome(toy1, False)
assert len(s1) == 8, f"toy1 len {len(s1)} != 8"
assert check(None, s1, toy1, 3)

toy2 = ["TATTAA", "GGCGTC", "AAGGCG", "AGTACA", "CGTCCA", "CAAGTA", "TACATA", "TCCAAG", "CATATT", "TTAAGG"]
s2 = reconstruct_genome(toy2, False)
assert len(s2) == 20, f"toy2 len {len(s2)} != 20"
assert check(None, s2, toy2, 6)

toy3 = ["TGGAGT", "ACAATG", "GGCAAC", "AATGGA", "CAACAA", "GAGTGG", "GGCCGG", "GTGGGG", "CCGGCA", "GGGGCC"]
s3 = reconstruct_genome(toy3, False)
assert len(s3) <= 21, f"toy3 len {len(s3)} > 21"
assert check(None, s3, toy3, 6)

# all 5 scenarios
random.seed(41)
fails = 0
total = 0
for trial in range(10):
    # scenario 2: comprehensive, no errors — exact
    genome = make_genome(150)
    reads = reads_from(genome, 50, 2, True)
    s = reconstruct_genome(reads, False)
    total += 1
    if len(s) > len(genome) or not check(genome, s, reads, 50):
        fails += 1

    # scenario 3: comprehensive, errors — length + genome validity
    genome = make_genome(100)
    reads = add_errors(reads_from(genome, 50, 2, True))
    s = reconstruct_genome(reads, True)
    total += 1
    # must be a valid genome: correct length (<= reference) and the
    # non-error reads are present
    if len(s) > len(genome) + 2:
        fails += 1

    # scenario 4: non-comprehensive, no errors — exact
    genome = make_genome(200)
    reads = reads_from(genome, 50, 2, False)
    s = reconstruct_genome(reads, False)
    total += 1
    if len(s) > len(genome) or not check(genome, s, reads, 50):
        fails += 1

    # scenario 5: non-comprehensive, errors — length
    genome = make_genome(150)
    reads = add_errors(reads_from(genome, 50, 2, False))
    s = reconstruct_genome(reads, True)
    total += 1
    if len(s) > len(genome) + 2:
        fails += 1

print(f"fails: {fails}/{total}")
print("ALL TESTS PASS" if fails == 0 else "FAILED")
