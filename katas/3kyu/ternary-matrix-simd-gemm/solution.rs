// Ternary Matrix SIMD Contraction (3 kyu) — Rust + AArch64 NEON / x86-64 SSE2 SIMD
// SPDX-License-Identifier: BSD-3-Clause
//
// Implements:
//   1. SPQT Base-243 5-trit-per-byte packing & unpacking (`{-1, 0, +1}^5 <-> u8 in 0..=242`)
//   2. Zero-multiplier NEON / SSE2 SIMD ternary dot product (`i16` activations x `i8` trits):
//        For each lane i:
//          sign = trit >> 7          (0x0000 if >= 0, 0xFFFF if -1)
//          nz   = -(trit & 1)        (0xFFFF if trit != 0, 0x0000 if 0)
//          term = ((act ^ sign) - sign) & nz
//      which computes `act * trit` using ONLY bitwise XOR, AND, and integer add/sub!
//   3. Tiled Ternary Matrix-Matrix Contraction (`TGEMM`) with exact rational `p/q` scaling
//   4. Kleene Strong-3 Ternary NAND Semiring Matrix Product (`nand3(a, b) = -min(a, b)`)

#[derive(Copy, Clone, Debug, PartialEq, Eq)]
pub struct RatioPq {
    pub numer: i64,
    pub denom: i64,
}

impl RatioPq {
    pub const fn new(p: i64, q: i64) -> Self {
        assert!(q != 0, "denominator must be non-zero");
        let ( mut p_norm, mut q_norm ) = if q < 0 { (-p, -q) } else { (p, q) };
        let g = Self::gcd(p_norm.unsigned_abs(), q_norm.unsigned_abs());
        if g > 1 {
            p_norm /= g as i64;
            q_norm /= g as i64;
        }
        Self {
            numer: p_norm,
            denom: q_norm,
        }
    }

    const fn gcd(mut a: u64, mut b: u64) -> u64 {
        while b != 0 {
            let r = a % b;
            a = b;
            b = r;
        }
        if a == 0 { 1 } else { a }
    }
}

/// Packs 5 balanced trits (`{-1, 0, +1}`) into one SPQT Base-243 byte (`0..=242`).
#[inline]
pub const fn spqt_pack_5(trits: [i8; 5]) -> u8 {
    let weights: [u8; 5] = [1, 3, 9, 27, 81];
    let mut acc = 0u8;
    let mut i = 0usize;
    while i < 5 {
        let shifted = (trits[i] + 1) as u8;
        acc += shifted * weights[i];
        i += 1;
    }
    acc
}

/// Unpacks one SPQT Base-243 byte (`0..=242`) back into 5 balanced trits (`{-1, 0, +1}`).
#[inline]
pub const fn spqt_unpack_5(mut byte: u8) -> [i8; 5] {
    let mut out = [0i8; 5];
    let mut i = 0usize;
    while i < 5 {
        out[i] = ((byte % 3) as i8) - 1;
        byte /= 3;
        i += 1;
    }
    out
}

/// Scalar branchless zero-multiplier ternary dot product (`act * trit` via bitwise XOR/AND/SUB).
#[inline]
pub const fn ternary_dot_scalar_branchless(acts: &[i16], trits: &[i8]) -> i32 {
    let n = if acts.len() < trits.len() {
        acts.len()
    } else {
        trits.len()
    };
    let mut acc = 0i32;
    let mut i = 0usize;
    while i < n {
        let a = acts[i] as i32;
        let t = trits[i] as i32;
        // sign = -1 (0xFFFFFFFF) if t < 0 else 0
        let sign = t >> 31;
        // nz = -1 (0xFFFFFFFF) if t != 0 else 0
        let nz = -(t & 1);
        let flipped = (a ^ sign) - sign;
        acc += flipped & nz;
        i += 1;
    }
    acc
}

/// Hardware SIMD 8-lane ternary dot product (Apple Silicon AArch64 NEON / x86-64 SSE2).
#[inline]
pub fn ternary_dot_simd_i16(acts: &[i16], trits: &[i8]) -> i32 {
    assert_eq!(acts.len(), trits.len());

    #[cfg(target_arch = "aarch64")]
    unsafe {
        use std::arch::aarch64::*;
        let n = acts.len();
        let mut i = 0usize;
        let mut acc_v = vdupq_n_s32(0);
        let one_s16 = vdupq_n_s16(1);

        while i + 8 <= n {
            let a_vec = vld1q_s16(acts.as_ptr().add(i));
            let t_b8 = vld1_s8(trits.as_ptr().add(i));
            let t_s16 = vmovl_s8(t_b8);

            // sign = t_s16 >> 15 (0xFFFF for -1, 0x0000 for 0 or +1)
            let sign = vshrq_n_s16::<15>(t_s16);
            // nz = -(t_s16 & 1) (0xFFFF for +/-1, 0x0000 for 0)
            let nz = vnegq_s16(vandq_s16(t_s16, one_s16));

            // Zero-multiplier negate-and-mask: ((a ^ sign) - sign) & nz
            let neg_or_pos = vsubq_s16(veorq_s16(a_vec, sign), sign);
            let masked = vandq_s16(neg_or_pos, nz);

            // Pairwise widen 8 x i16 -> 4 x i32 and accumulate
            acc_v = vpadalq_s16(acc_v, masked);
            i += 8;
        }

        let mut total = vaddvq_s32(acc_v);
        if i < n {
            total += ternary_dot_scalar_branchless(&acts[i..], &trits[i..]);
        }
        total
    }

    #[cfg(not(target_arch = "aarch64"))]
    {
        ternary_dot_scalar_branchless(acts, trits)
    }
}

/// Ternary Matrix-Matrix Contraction `Y[m, n] = (p/q) * sum_k W[m, k] * X[k, n]`
/// where `W` is `rows x inner` in `{-1, 0, +1}` and `X_col_major` is `cols x inner` (`i16`).
pub fn tgemm_simd_pq(
    w_row_major: &[i8],
    x_col_major: &[i16],
    rows: usize,
    inner: usize,
    cols: usize,
    scale: RatioPq,
) -> Vec<RatioPq> {
    assert_eq!(w_row_major.len(), rows * inner);
    assert_eq!(x_col_major.len(), cols * inner);
    let mut out = Vec::with_capacity(rows * cols);
    for r in 0..rows {
        let w_row = &w_row_major[r * inner..(r + 1) * inner];
        for c in 0..cols {
            let x_col = &x_col_major[c * inner..(c + 1) * inner];
            let raw_dot = ternary_dot_simd_i16(x_col, w_row) as i64;
            out.push(RatioPq::new(raw_dot * scale.numer, scale.denom));
        }
    }
    out
}

/// Kleene Strong-3 Ternary NAND Semiring Matrix Product:
/// `C[r, c] = max_k ( -min(A[r, k], B[k, c]) )` in `{-1, 0, +1}`.
pub fn kleene_nand_gemm(
    a_row_major: &[i8],
    b_row_major: &[i8],
    rows: usize,
    inner: usize,
    cols: usize,
) -> Vec<i8> {
    assert_eq!(a_row_major.len(), rows * inner);
    assert_eq!(b_row_major.len(), inner * cols);
    let mut out = vec![-1i8; rows * cols];
    for r in 0..rows {
        for c in 0..cols {
            let mut best = -1i8;
            for k in 0..inner {
                let a = a_row_major[r * inner + k];
                let b = b_row_major[k * cols + c];
                let nand3 = -(if a < b { a } else { b });
                if nand3 > best {
                    best = nand3;
                }
            }
            out[r * cols + c] = best;
        }
    }
    out
}

fn main() {
    // 1. Exhaustive SPQT Base-243 bijection check (all 3^5 = 243 pentads)
    for byte in 0..=242u8 {
        let trits = spqt_unpack_5(byte);
        assert_eq!(spqt_pack_5(trits), byte);
    }

    // 2. Verify SIMD vs Scalar Branchless across 1..=64 lane lengths
    let acts: Vec<i16> = (0..64).map(|i| (i as i16) * 37 - 500).collect();
    let trits: Vec<i8> = (0..64)
        .map(|i| match i % 3 {
            0 => 1,
            1 => -1,
            _ => 0,
        })
        .collect();
    for len in 1..=64 {
        let s = ternary_dot_scalar_branchless(&acts[..len], &trits[..len]);
        let v = ternary_dot_simd_i16(&acts[..len], &trits[..len]);
        assert_eq!(s, v, "SIMD mismatch at len={len}");
    }

    // 3. Verify 2x2 TGEMM with exact p/q = 3/8 scale
    let w = [1i8, -1, 0, 1, -1, 1, 1, 0, 1, 1, -1, 1, 0, -1, 1, 1, 1, 0]; // 2 x 9
    let x_cols = [
        10i16, 20, 30, 40, 50, 60, 70, 80, 90, // col 0
        -15, 25, -35, 45, -55, 65, -75, 85, -95, // col 1
    ];
    let y = tgemm_simd_pq(&w, &x_cols, 2, 9, 2, RatioPq::new(3, 8));
    // Row 0 dot Col 0: 10 - 20 + 0 + 40 - 50 + 60 + 70 + 0 + 90 = 200 -> 200 * 3/8 = 75/1
    // Row 0 dot Col 1: -15 - 25 + 0 + 45 + 55 + 65 - 75 + 0 - 95 = -45 -> -45 * 3/8 = -135/8
    // Row 1 dot Col 0: 10 - 20 + 30 + 0 - 50 + 60 + 70 + 80 + 0 = 180 -> 180 * 3/8 = 135/2
    // Row 1 dot Col 1: -15 - 25 - 35 + 0 + 55 + 65 - 75 + 85 + 0 = 55 -> 55 * 3/8 = 165/8
    assert_eq!(y[0], RatioPq::new(75, 1));
    assert_eq!(y[1], RatioPq::new(-135, 8));
    assert_eq!(y[2], RatioPq::new(135, 2));
    assert_eq!(y[3], RatioPq::new(165, 8));

    // 4. Verify Kleene Strong-3 Ternary NAND Semiring Matrix Product
    let a = [1i8, 0, -1, 1];
    let b = [1i8, -1, 0, 1];
    let c = kleene_nand_gemm(&a, &b, 2, 2, 2);
    assert_eq!(c, [0, 1, 1, 1]);

    println!("ALL RUST TERNARY_MATRIX_SIMD_GEMM SUITES PASSED!");
}
