use express_number_as_sum_of_four_squares::four_squares;
use num::bigint::BigInt;

pub fn sum_quad(quad: (BigInt, BigInt, BigInt, BigInt)) -> BigInt {
    &quad.0 + &quad.1 + &quad.2 + &quad.3
}

pub fn square_quad(quad: (BigInt, BigInt, BigInt, BigInt)) -> (BigInt, BigInt, BigInt, BigInt) {
    (
        &quad.0 * &quad.0,
        &quad.1 * &quad.1,
        &quad.2 * &quad.2,
        &quad.3 * &quad.3,
    )
}

fn test_solution(n: BigInt) {
    let numbers = four_squares(n.clone());
    assert!(numbers.0 >= BigInt::from(0));
    assert!(numbers.1 >= BigInt::from(0));
    assert!(numbers.2 >= BigInt::from(0));
    assert!(numbers.3 >= BigInt::from(0));
    let squares = square_quad(numbers);
    let sum = sum_quad(squares.clone());
    assert_eq!(sum, n, "The sum of {:?} is {sum} but should be {n}", squares);
}

#[test]
fn static_tests() {
    for i in [0, 1, 2, 3, 4, 5, 6, 7, 8, 15, 23, 57, 489, 677, 2u32.pow(16) - 3] {
        test_solution(BigInt::from(i));
    }
    test_solution(BigInt::from(242737486475111359018937623004230274909u128));
}

#[test]
fn random_128_and_1024_bit_tests() {
    let start = std::time::Instant::now();
    let mut state = 0x853c49e6748fea9bu64;
    let mut next_u64 = || {
        state = state
            .wrapping_mul(6364136223846793005)
            .wrapping_add(1442695040888963407);
        state
    };

    for _ in 0..20 {
        let hi = next_u64() as u128 | (1u128 << 63);
        let lo = next_u64() as u128;
        let n = BigInt::from((hi << 64) | lo);
        test_solution(n);
    }

    for _ in 0..20 {
        let mut n = BigInt::from(0);
        for w in 0..16 {
            let mut word = next_u64();
            if w == 15 {
                word |= 1u64 << 63;
            }
            n = (n << 64) + BigInt::from(word);
        }
        test_solution(n);
    }

    let pow1024 = BigInt::from(1u32) << 1024;
    for delta in [0i32, -1, -3, -5, -7, -9, -15, -33, -57] {
        test_solution(&pow1024 + BigInt::from(delta));
    }
    test_solution(BigInt::from(7u32) << 1000);

    let elapsed = start.elapsed();
    println!("Solved 20x128b + 20x1024b + 10 edge cases in {:?}", elapsed);
    assert!(elapsed.as_millis() < 500, "Took too long: {:?}", elapsed);
}
