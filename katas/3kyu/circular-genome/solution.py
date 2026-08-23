"""Assembling a Circular Genome (Shortest Common Superstring) — Codewars.

Given equal-length reads (A/T/C/G), reconstruct a plausible minimum-length
circular genome string containing all reads. Must be <= the reference
solution's length. Reads may have single mismatch errors (error_prone) and
may not cover the whole genome (is_comprehensive).

Strategy:
- Without errors: greedy overlap assembly (merge the pair with the largest
  suffix-prefix overlap until one string remains), then remove the circular
  wrap tail. Reconstructs spacing-2 reads exactly.
- With errors: incremental consensus. All pairwise overlaps are precomputed
  once (allowing 1 mismatch, early-exit counting). Each read is placed at
  its best offset relative to the placed reads, then the consensus is taken
  by majority vote at every position.
"""


def reconstruct_genome(reads, has_errors=False):
    reads = list(dict.fromkeys(reads))
    k = len(reads[0])
    n = len(reads)
    max_m = 1 if has_errors else 0

    def overlap(a, b):
        best = 0
        for i in range(k - 1, 0, -1):
            mism = 0
            ok = True
            for x, y in zip(a[-i:], b[:i]):
                if x != y:
                    mism += 1
                    if mism > max_m:
                        ok = False
                        break
            if ok:
                return i
        return 0

    if not has_errors:
        while len(reads) > 1:
            best_a = best_b = None
            best_ov = -1
            for i in range(len(reads)):
                for j in range(len(reads)):
                    if i == j:
                        continue
                    ov = overlap(reads[i], reads[j])
                    if ov > best_ov:
                        best_ov = ov
                        best_a, best_b = i, j
            if best_ov <= 0:
                reads[0] = reads[0] + reads[1]
                reads.pop(1)
                continue
            a, b = reads[best_a], reads[best_b]
            reads[best_a] = a + b[best_ov:]
            reads.pop(best_b)
        genome = reads[0]
        best_k = 0
        for kk in range(1, len(genome)):
            if genome[-kk:] == genome[:kk]:
                best_k = kk
        return genome[:-best_k] if best_k else genome

    # ---- error-prone: incremental consensus ----
    # precompute pairwise overlaps
    ov = [[0] * n for _ in range(n)]
    for i in range(n):
        for j in range(n):
            if i != j:
                ov[i][j] = overlap(reads[i], reads[j])

    placed = [(0, 0)]  # (read index, offset)
    remaining = list(range(1, n))

    while remaining:
        best = None
        best_score = -1
        for ri in remaining:
            for pi, (p, poff) in enumerate(placed):
                o = ov[p][ri]
                if o > best_score:
                    best_score = o
                    best = ("after", pi, ri)
                o2 = ov[ri][p]
                if o2 > best_score:
                    best_score = o2
                    best = ("before", pi, ri)
        if best is None or best_score <= 0:
            last_off = placed[-1][1]
            placed.append((remaining[0], last_off + k))
            remaining.pop(0)
            continue
        kind, pi, ri = best
        if kind == "after":
            p, poff = placed[pi]
            placed.insert(pi + 1, (ri, poff + (k - ov[p][ri])))
        else:
            p, poff = placed[pi]
            placed.insert(pi, (ri, poff - (k - ov[ri][p])))
        remaining.remove(ri)

    # consensus from placed reads
    min_off = min(off for _, off in placed)
    max_off = max(off for _, off in placed) + k
    counts = [{} for _ in range(max_off - min_off)]
    for ri, off in placed:
        base = off - min_off
        for p in range(k):
            ch = reads[ri][p]
            counts[base + p][ch] = counts[base + p].get(ch, 0) + 1
    consensus = []
    for col in counts:
        if not col:
            continue
        consensus.append(max(col, key=col.get))
    genome = "".join(consensus)

    # circular wrap: the tail may overlap the head (with errors, allow
    # mismatches). Remove the longest duplicated prefix.
    best_k = 0
    for kk in range(1, len(genome)):
        tail = genome[-kk:]
        head = genome[:kk]
        mism = sum(1 for x, y in zip(tail, head) if x != y)
        if mism <= max(1, kk // 8):
            best_k = kk
    return genome[:-best_k] if best_k else genome
