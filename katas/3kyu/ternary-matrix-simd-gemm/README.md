# Balanced-Ternary Matrix SIMD Contraction (`quantTernP/Q` + NEON/SSE4.1 + Kleene NAND)

- **Kyu**: 3 kyu (Sovereign E2E Kata)
- **Languages**: Rust (`solution.rs`), Apple Silicon AArch64 NEON Assembly (`solution_arm64.s`), x86-64 NASM SIMD (`solution.asm`), SWI-Prolog 8.0+ (`solution.pl`, `test.pl`)

## Problem Statement

Given a balanced-ternary weight matrix $W \in \{-1, 0, +1\}^{M \times K}$, an `int16_t` activation matrix $X \in \mathbb{Z}_{16}^{K \times N}$, and an exact rational scale $p/q$:

1. **SPQT Base-243 Bijection (`spqt_pack_5` / `spqt_unpack_5`)**: Pack 5 balanced trits $t_0..t_4 \in \{-1, 0, +1\}$ into a single byte $b = \sum_{j=0}^{4} (t_j + 1) \cdot 3^j \in [0..242]$ ($99.1\%$ Shannon density).
2. **Zero-Multiplier SIMD Ternary Contraction (`ternary_dot_simd_i16` / `_ternary_dot_neon_i16`)**: Compute $Y_{m, n} = (p/q) \sum_{k=0}^{K-1} W_{m, k} X_{k, n}$ without integer multiply instructions inside the inner loop:
   - **AArch64 NEON (`solution_arm64.s` & `solution.rs`)**: Uses `sshll`, `sshr #15` (sign mask), `cmtst` / `neg(t & 1)` (non-zero mask), `eor` + `sub` + `and` (`((act ^ sign) - sign) & nz`), and `sadalp` + `addv` pairwise 16-to-32-bit accumulation.
   - **x86-64 SSE4.1/AVX2 (`solution.asm`)**: Uses `pmovsxbw`, `psignw`, and 32-bit widened accumulation.
3. **Kleene Strong-3 Ternary NAND Semiring Product (`kleene_nand_gemm`)**: Compute $(A \circledast B)_{m, n} = \max_k (-\min(A_{m,k}, B_{k,n})) \in \{-1, 0, +1\}$.
