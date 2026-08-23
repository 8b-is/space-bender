# Assembling a Circular Genome (Shortest Common Superstring)

**Kyu:** 3 · **Source:** Codewars (ALowVerus)

Given a set of equal-length reads (A/T/C/G), reconstruct a plausible
minimum-length **circular** genome string that contains all reads. The
answer must be at most the reference solution's length. Reads may carry a
single mismatch error (`has_errors=True`) and may not span the whole genome
(`is_comprehensive=False`).

## Solution

Greedy overlap assembly:

1. **Deduplicate** reads (identical reads are statistically impossible in
   real sequencing and should be ignored).
2. Repeatedly find the pair of reads with the **largest suffix-prefix
   overlap** and merge them (`a + b[overlap:]`), until one string remains.
3. **Circular wrap**: since the genome is circular, the assembly's tail may
   overlap its own head — remove the longest duplicated prefix (the
   wrap-around tail).

The greedy always merges the strongest overlap first, which for
spacing-2 reads (the kata's test pattern) reconstructs the genome exactly.
Mismatch errors are absorbed naturally: reads still overlap by k-1
characters, so the assembly stays correct and the error appears as a
single substitution in the final string (acceptable — the kata only
requires the output to contain the reads and be within the reference
length).

## Files

- `solution.py` — the assembler
- `test_solution.py` — scenario verification
