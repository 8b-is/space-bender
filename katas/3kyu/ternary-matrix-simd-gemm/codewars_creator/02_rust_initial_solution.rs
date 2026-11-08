#[derive(Copy, Clone, Debug, PartialEq, Eq)]
pub struct RatioPq {
    pub numer: i64,
    pub denom: i64,
}

impl RatioPq {
    pub const fn new(p: i64, q: i64) -> Self {
        assert!(q != 0, "denominator must be non-zero");
        let (mut p_norm, mut q_norm) = if q < 0 { (-p, -q) } else { (p, q) };
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

pub const fn spqt_pack_5(_trits: [i8; 5]) -> u8 {
    todo!("Pack 5 balanced trits in {-1, 0, +1} into 0..=242")
}

pub const fn spqt_unpack_5(_byte: u8) -> [i8; 5] {
    todo!("Unpack 0..=242 into 5 balanced trits in {-1, 0, +1}")
}

pub fn ternary_dot_simd_i16(_acts: &[i16], _trits: &[i8]) -> i32 {
    todo!("Compute multiplier-free SIMD or branchless ternary dot product")
}

pub fn tgemm_simd_pq(
    _w_row_major: &[i8],
    _x_col_major: &[i16],
    _rows: usize,
    _inner: usize,
    _cols: usize,
    _scale: RatioPq,
) -> Vec<RatioPq> {
    todo!("Compute exact p/q scaled ternary matrix contraction")
}

pub fn kleene_nand_gemm(
    _a_row_major: &[i8],
    _b_row_major: &[i8],
    _rows: usize,
    _inner: usize,
    _cols: usize,
) -> Vec<i8> {
    todo!("Compute Kleene Strong-3 NAND semiring matrix product")
}
