# Balanced-Ternary Matrix SIMD Contraction (`quantTernP/Q` + SPQT Base-243 + Kleene NAND)

Modern ternary neural network accelerators (`quantTernP/Q`, BitNet b1.58, FELIX/PHOENIX) replace 16-bit floating-point weights with **balanced trits** $t \in \{-1, 0, +1\}$ paired with an exact rational block scale $p/q$.

In this kata you will implement four core primitives of a balanced-ternary matrix engine:

---

### 1. SPQT Base-243 Packing (`spqt_pack_5` & `spqt_unpack_5`)

Five balanced trits $t_0, t_1, t_2, t_3, t_4 \in \{-1, 0, +1\}$ map bijectively onto a single unsigned byte $b \in [0..242]$ ($3^5 = 243 \le 256$, achieving $7.925 / 8 = 99.06\%$ Shannon density):

$$b = \sum_{j=0}^{4} (t_j + 1) \cdot 3^j$$

---

### 2. Multiplier-Free Ternary Dot Product (`ternary_dot_simd_i16` / `ternary_dot_branchless`)

Given an activation slice `acts: &[i16]` and a balanced-trit slice `trits: &[i8]` of equal length $K$, compute:

$$\text{dot} = \sum_{k=0}^{K-1} \text{acts}[k] \cdot \text{trits}[k] \in \mathbb{Z}_{32}$$

**Hardware / Algorithmic Insight**: Because each trit is in $\{-1, 0, +1\}$, multiplication can be replaced entirely by bitwise two's-complement negation and masking (or 8-lane AArch64 NEON `veorq_s16` / `vsubq_s16` / `vandq_s16` / `vpadalq_s16` or x86-64 `psignw`):

$$\text{sign} = t \gg 31, \quad \text{nz} = -(t \mathbin{\&} 1), \quad \text{term} = ((a \oplus \text{sign}) - \text{sign}) \mathbin{\&} \text{nz}$$

---

### 3. Exact Rational `p/q` Ternary GEMM (`tgemm_simd_pq` / `tgemm_pq`)

Given a row-major ternary weight matrix $W \in \{-1, 0, +1\}^{M \times K}$, a column-major `i16` activation matrix $X \in \mathbb{Z}_{16}^{N \times K}$, and an exact rational scale $p/q$ (`RatioPq { numer, denom }` reduced with $\gcd(|p|, q) = 1$ and $q > 0$), return the row-major $M \times N$ output matrix:

$$Y_{m, n} = \text{reduce}\!\left(\frac{p}{q} \sum_{k=0}^{K-1} W_{m, k} \cdot X_{n, k}\right)$$

---

### 4. Kleene Strong-3 Ternary NAND Semiring Matrix Product (`kleene_nand_gemm`)

In Kleene's strong three-valued logic $\mathcal{K}_3 = \{-1, 0, +1\}$, ternary NAND is defined as:

$$\text{nand}_3(a, b) = -\min(a, b)$$

Given row-major ternary matrices $A \in \{-1, 0, +1\}^{M \times K}$ and $B \in \{-1, 0, +1\}^{K \times N}$, compute their tropical/Kleene semiring matrix product $C \in \{-1, 0, +1\}^{M \times N}$:

$$C_{m, n} = \max_{0 \le k < K} \bigl(-\min(A_{m, k}, B_{k, n})\bigr)$$
