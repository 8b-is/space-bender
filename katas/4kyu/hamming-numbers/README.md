# Hamming Numbers (NASM x86-64)

**Kyu:** 4 · **Source:** [Codewars](https://www.codewars.com/kata/526d84b98f428f14a60008da/nasm) · **ID:** `526d84b98f428f14a60008da`
(NASM x86-64, by `xcthulhu`)

A *Hamming number* (5-smooth number) is a positive integer of the form $2^i 3^j 5^k$ for non-negative integers $i, j, k$. Compute the $n$-th smallest Hamming number for $1 \le n \le 13,282$ (`hamming(13282) = 18,432,000,000,000,000,000`, the largest 5-smooth number below $2^{64}$).

## Solution

We use Dijkstra's 3-pointer dynamic programming algorithm in x86-64 NASM (`System V AMD64 ABI`, `nasm -f elf64`) with a `.bss`-backed memoization table `table[0..13281]`:

1. **One-time $O(N)$ Table Initialization (`.init`)**:
   - On the first call (`cmp qword [r8], 0`), we populate all $13,282$ 64-bit Hamming numbers into `.bss` in a single tight register-only loop (`141` bytes of `.text` total).
   - Three stream indices `i2` (`rsi`), `i3` (`rdx`), `i5` (`r9`) and three current candidates `x2` (`r10`), `x3` (`r11`), `x5` (`rdi`) start at `(0, 0, 0)` and `(2, 3, 5)`.
   - At each step $k \in [1, 13281]$:
     - `m = min(x2, x3, x5)` is selected branchlessly via unsigned conditional moves (`cmovb rax, r11` and `cmovb rax, rdi` — unsigned `cmovb` is essential because values above $n \approx 11,960$ exceed $2^{63}-1$ and set bit 63).
     - `table[k] = m` is written to `[r8 + rcx*8]`.
     - Any stream matching `m` advances its index and updates its candidate without `mul` instructions:
       - $\times 2$: `add r10, r10`
       - $\times 3$: `lea r11, [r11 + r11*2]`
       - $\times 5$: `lea rdi, [rdi + rdi*4]`
2. **$O(1)$ Fast Path for All Subsequent Calls**:
   - Once `table[0] = 1` is initialized, every subsequent `hamming(n)` call executes 6 instructions (`mov edi, edi` → `lea r8, [rel table]` → `cmp` → `je` → `mov rax, [r8 + rdi*8 - 8]` → `ret`).

## Files

- `solution.asm` — x86-64 NASM implementation (`hamming` / `hamber`, 141 bytes `.text`)
- `test_solution.py` — assembles `solution.asm` with `nasm -f elf64`, relocates `.rela.text`, and executes the x86-64 machine code across all $1 \le n \le 13,282$
- `bluesky-receipt.json` — published 4-post ELI5 educational Bluesky thread ([Root: `3mz3siseu362n`](https://bsky.app/profile/0xp3t3rl.bsky.social/post/3mz3siseu362n))
