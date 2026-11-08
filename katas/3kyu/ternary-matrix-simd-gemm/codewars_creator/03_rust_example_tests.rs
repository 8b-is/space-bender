#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_spqt_base243_bijection() {
        for byte in 0..=242u8 {
            let trits = spqt_unpack_5(byte);
            assert!(trits.iter().all(|&t| (-1..=1).contains(&t)));
            assert_eq!(spqt_pack_5(trits), byte);
        }
    }

    #[test]
    fn test_tgemm_exact_pq() {
        let w = [1i8, -1, 0, 1, -1, 1, 1, 0, 1, 1, -1, 1, 0, -1, 1, 1, 1, 0];
        let x_cols = [
            10i16, 20, 30, 40, 50, 60, 70, 80, 90,
            -15, 25, -35, 45, -55, 65, -75, 85, -95,
        ];
        let y = tgemm_simd_pq(&w, &x_cols, 2, 9, 2, RatioPq::new(3, 8));
        assert_eq!(
            y,
            vec![
                RatioPq::new(75, 1),
                RatioPq::new(-135, 8),
                RatioPq::new(135, 2),
                RatioPq::new(165, 8),
            ]
        );
    }

    #[test]
    fn test_kleene_nand_semiring() {
        let a = [1i8, 0, -1, 1];
        let b = [1i8, -1, 0, 1];
        assert_eq!(kleene_nand_gemm(&a, &b, 2, 2, 2), vec![0, 1, 1, 1]);
    }
}
