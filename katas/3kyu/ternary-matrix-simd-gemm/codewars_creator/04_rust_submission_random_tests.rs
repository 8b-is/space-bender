#[cfg(test)]
mod submission_tests {
    use super::*;

    struct SplitMix64(u64);
    impl SplitMix64 {
        fn next(&mut self) -> u64 {
            self.0 = self.0.wrapping_add(0x9E37_79B9_7F4A_7C15);
            let mut z = self.0;
            z = (z ^ (z >> 30)).wrapping_mul(0xBF58_476D_1CE4_E5B9);
            z = (z ^ (z >> 27)).wrapping_mul(0x94D0_49BB_1331_11EB);
            z ^ (z >> 31)
        }
    }

    fn ref_tgemm(
        w: &[i8],
        x_cols: &[i16],
        rows: usize,
        inner: usize,
        cols: usize,
        scale: RatioPq,
    ) -> Vec<RatioPq> {
        let mut out = Vec::with_capacity(rows * cols);
        for r in 0..rows {
            for c in 0..cols {
                let mut dot = 0i64;
                for k in 0..inner {
                    dot += (w[r * inner + k] as i64) * (x_cols[c * inner + k] as i64);
                }
                out.push(RatioPq::new(dot * scale.numer, scale.denom));
            }
        }
        out
    }

    fn ref_kleene_nand(a: &[i8], b: &[i8], rows: usize, inner: usize, cols: usize) -> Vec<i8> {
        let mut out = vec![-1i8; rows * cols];
        for r in 0..rows {
            for c in 0..cols {
                let mut best = -1i8;
                for k in 0..inner {
                    let v = -(a[r * inner + k].min(b[k * cols + c]));
                    if v > best {
                        best = v;
                    }
                }
                out[r * cols + c] = best;
            }
        }
        out
    }

    #[test]
    fn test_100_randomized_simd_tgemm_and_kleene_matrices() {
        let mut rng = SplitMix64(0x8B15_2026_CAFE_BEEF);
        for trial in 0..100 {
            let rows = 1 + (rng.next() as usize % 8);
            let inner = 1 + (rng.next() as usize % 64);
            let cols = 1 + (rng.next() as usize % 8);

            let w: Vec<i8> = (0..rows * inner)
                .map(|_| (rng.next() % 3) as i8 - 1)
                .collect();
            let x_cols: Vec<i16> = (0..cols * inner)
                .map(|_| ((rng.next() % 8192) as i32 - 4096) as i16)
                .collect();
            let b_mat: Vec<i8> = (0..inner * cols)
                .map(|_| (rng.next() % 3) as i8 - 1)
                .collect();

            let p = ((rng.next() % 31) as i64) - 15;
            let q = 1 + (rng.next() % 32) as i64;
            let scale = RatioPq::new(if p == 0 { 3 } else { p }, q);

            let expected_y = ref_tgemm(&w, &x_cols, rows, inner, cols, scale);
            let actual_y = tgemm_simd_pq(&w, &x_cols, rows, inner, cols, scale);
            assert_eq!(actual_y, expected_y, "TGEMM mismatch on trial {trial}");

            let expected_k = ref_kleene_nand(&w, &b_mat, rows, inner, cols);
            let actual_k = kleene_nand_gemm(&w, &b_mat, rows, inner, cols);
            assert_eq!(actual_k, expected_k, "Kleene NAND mismatch on trial {trial}");
        }
    }
}
