# ELI5 · Balanced-Ternary Matrix SIMD Contraction (`3 kyu`)

## 1. The Kid-Friendly Story
Imagine a neural network weight matrix $A$ where every weight is only **`-1`**, **`0`**, or **`+1`** (a **balanced trit**).
- Why waste 16-bit or 32-bit floats storing `-1, 0, +1` when **5 trits fit inside 1 single byte** ($3^5 = 243 \le 255$)?
- Even better: when you multiply a number $b$ by a trit $t \in \{-1, 0, +1\}$, you **never need a multiplication instruction**:
  - $t = +1 \implies \text{add } b$ (`acc += b`)
  - $t = -1 \implies \text{subtract } b$ (`acc -= b`)
  - $t = 0 \implies \text{skip!}$

## 2. Step-by-Step Breakdown
1. **Base-243 Unpacking (`unpack_base243_byte`)**:
   - Each byte $v \in [0, 242]$ encodes 5 trits from LSB to MSB:
     $$v = \sum_{j=0}^4 (t_j + 1) \cdot 3^j$$
   - Repeatedly take `(v % 3) - 1` and `v /= 3` five times to recover $t_0, \dots, t_4 \in \{-1, 0, +1\}$.
2. **2-Bit Bitplane Split (`pos_mask`, `neg_mask`)**:
   - Store $+1$ positions in `pos_mask` and $-1$ positions in `neg_mask`.
   - Any $k$ where both bits are `0` is a zero trit and is skipped in $O(1)$ via `trailing_zeros()`.
3. **4-Lane SIMD Contraction (`vaddq_s32` / `vsubq_s32`)**:
   - On Apple Silicon AArch64 NEON (`solution.rs`, `solution_arm64.s`) and x86-64 NASM (`solution.asm`), each non-zero trit updates 4 `i32` columns simultaneously using vector add/subtract with **zero multiplications and zero floats**.
