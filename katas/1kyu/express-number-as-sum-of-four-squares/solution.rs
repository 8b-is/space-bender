use num::bigint::{BigInt, BigUint, Sign};
use num::traits::{One, ToPrimitive, Zero};

type U320 = [u64; 5];

const SMALL_PRIMES: [u32; 96] = [
    3, 5, 7, 11, 13, 17, 19, 23, 29, 31, 37, 41, 43, 47, 53, 59, 61, 67, 71, 73, 79, 83, 89, 97,
    101, 103, 107, 109, 113, 127, 131, 137, 139, 149, 151, 157, 163, 167, 173, 179, 181, 191, 193,
    197, 199, 211, 223, 227, 229, 233, 239, 241, 251, 257, 263, 269, 271, 277, 281, 283, 293, 307,
    311, 313, 317, 331, 337, 347, 349, 353, 359, 367, 373, 379, 383, 389, 397, 401, 409, 419, 421,
    431, 433, 439, 443, 449, 457, 461, 463, 467, 479, 487, 491, 499, 503, 509,
];

const NON_RESIDUE_BASES: [u64; 32] = [
    2, 3, 5, 6, 7, 10, 11, 13, 14, 15, 17, 19, 21, 22, 23, 26, 29, 31, 33, 34, 35, 37, 38, 41, 43,
    47, 51, 53, 55, 57, 58, 59,
];

#[inline]
fn u64_mod_mul(a: u64, b: u64, m: u64) -> u64 {
    ((a as u128 * b as u128) % (m as u128)) as u64
}

#[inline]
fn u64_mod_pow(mut base: u64, mut exp: u64, m: u64) -> u64 {
    let mut res = 1u64;
    base %= m;
    while exp > 0 {
        if (exp & 1) != 0 {
            res = u64_mod_mul(res, base, m);
        }
        base = u64_mod_mul(base, base, m);
        exp >>= 1;
    }
    res
}

fn is_prime_u64(n: u64) -> bool {
    if n < 2 {
        return false;
    }
    if n == 2 || n == 3 || n == 5 || n == 7 {
        return true;
    }
    if (n & 1) == 0 || n % 3 == 0 || n % 5 == 0 || n % 7 == 0 {
        return false;
    }
    let d = (n - 1) >> (n - 1).trailing_zeros();
    let s = (n - 1).trailing_zeros();
    for &a in &[2u64, 325, 9375, 28178, 450775, 9780504, 1795265022] {
        if a % n == 0 {
            continue;
        }
        let mut x = u64_mod_pow(a, d, n);
        if x == 1 || x == n - 1 {
            continue;
        }
        let mut composite = true;
        for _ in 1..s {
            x = u64_mod_mul(x, x, n);
            if x == n - 1 {
                composite = false;
                break;
            }
        }
        if composite {
            return false;
        }
    }
    true
}

#[inline]
fn isqrt_u128(n: u128) -> u128 {
    if n < 2 {
        return n;
    }
    let shift = (128 - n.leading_zeros() + 1) >> 1;
    let mut x = 1u128 << shift;
    loop {
        let nx = (x + n / x) >> 1;
        if nx >= x {
            return x;
        }
        x = nx;
    }
}

#[inline]
fn isqrt_u64(n: u64) -> u64 {
    if n < 2 {
        return n;
    }
    let mut x = (n as f64).sqrt() as u64;
    x = (x + n / x) >> 1;
    if x > 0 && x > n / x {
        x -= 1;
    } else if (x + 1) <= n / (x + 1) {
        x += 1;
    }
    x
}

fn cornacchia_u64(p: u64) -> Option<(u64, u64)> {
    if p == 2 {
        return Some((1, 1));
    }
    let exp = (p - 1) >> 2;
    let mut z = 0u64;
    for &g in &NON_RESIDUE_BASES {
        if g >= p {
            break;
        }
        let cand = u64_mod_pow(g, exp, p);
        if u64_mod_mul(cand, cand, p) == p - 1 {
            z = cand;
            break;
        }
    }
    if z == 0 {
        let mut g = 61u64;
        while g < p {
            let cand = u64_mod_pow(g, exp, p);
            if u64_mod_mul(cand, cand, p) == p - 1 {
                z = cand;
                break;
            }
            g += 2;
        }
    }
    if z == 0 {
        return None;
    }
    let mut a = p;
    let mut b = z;
    let limit = isqrt_u64(p);
    while b > limit {
        let r = a % b;
        a = b;
        b = r;
    }
    let rem = p - b * b;
    let c = isqrt_u64(rem);
    if b * b + c * c == p {
        Some((b, c))
    } else {
        None
    }
}

fn solve_u128(n: u128) -> (u128, u128, u128, u128) {
    if n == 0 {
        return (0, 0, 0, 0);
    }
    let tz = n.trailing_zeros();
    let shift = tz >> 1;
    let m = n >> (shift << 1);

    let s1 = isqrt_u128(m);
    if s1 * s1 == m {
        return (s1 << shift, 0, 0, 0);
    }

    let rem4 = (m & 3) as u8;
    let pa = if rem4 == 3 { 1u128 } else { 0u128 };
    let pb = if rem4 == 1 { 0u128 } else { 1u128 };

    let mut a = if (s1 & 1) == pa { s1 } else { s1 - 1 };
    loop {
        let r1 = m - a * a;
        let s2 = isqrt_u128(r1);
        if s2 * s2 == r1 {
            return (a << shift, s2 << shift, 0, 0);
        }
        let mut b = if (s2 & 1) == pb { s2 } else { s2.wrapping_sub(1) };
        let mut steps = 0usize;
        while b <= s2 && steps < 256 {
            let p128 = r1 - b * b;
            if p128 == 1 {
                return (a << shift, b << shift, 1u128 << shift, 0);
            }
            if p128 <= u64::MAX as u128 {
                let p = p128 as u64;
                if is_prime_u64(p) {
                    if let Some((c, d)) = cornacchia_u64(p) {
                        return (
                            a << shift,
                            b << shift,
                            (c as u128) << shift,
                            (d as u128) << shift,
                        );
                    }
                }
            }
            if b < 2 {
                break;
            }
            b -= 2;
            steps += 1;
        }
        if a < 2 {
            break;
        }
        a -= 2;
    }
    unreachable!("Lagrange four-square decomposition always exists for u128")
}

// ============================================================================
// Stack-allocated 320-bit (5 x u64) Montgomery + Euclidean Engine
// ============================================================================

#[inline]
fn biguint_to_u320(x: &BigUint) -> Option<U320> {
    if x.bits() > 318 {
        return None;
    }
    let digits = x.to_u64_digits();
    let mut out = [0u64; 5];
    for (i, &d) in digits.iter().enumerate().take(5) {
        out[i] = d;
    }
    Some(out)
}

#[inline]
fn u320_to_biguint(x: &U320) -> BigUint {
    BigUint::from_slice(&[
        x[0] as u32,
        (x[0] >> 32) as u32,
        x[1] as u32,
        (x[1] >> 32) as u32,
        x[2] as u32,
        (x[2] >> 32) as u32,
        x[3] as u32,
        (x[3] >> 32) as u32,
        x[4] as u32,
        (x[4] >> 32) as u32,
    ])
}

#[inline]
fn u320_cmp(a: &U320, b: &U320) -> core::cmp::Ordering {
    for i in (0..5).rev() {
        if a[i] != b[i] {
            return a[i].cmp(&b[i]);
        }
    }
    core::cmp::Ordering::Equal
}

#[inline]
fn u320_is_zero(a: &U320) -> bool {
    (a[0] | a[1] | a[2] | a[3] | a[4]) == 0
}

#[inline]
fn u320_bitlen(a: &U320) -> usize {
    for i in (0..5).rev() {
        if a[i] != 0 {
            return i * 64 + (64 - a[i].leading_zeros() as usize);
        }
    }
    0
}

#[inline]
fn u320_get_bit(a: &U320, bit: usize) -> bool {
    let limb = bit >> 6;
    let offset = bit & 63;
    if limb >= 5 {
        false
    } else {
        ((a[limb] >> offset) & 1) != 0
    }
}

#[inline]
fn u320_sub_assign(a: &mut U320, b: &U320) {
    let mut borrow = 0u64;
    for i in 0..5 {
        let (d1, b1) = a[i].overflowing_sub(b[i]);
        let (d2, b2) = d1.overflowing_sub(borrow);
        a[i] = d2;
        borrow = (b1 as u64) + (b2 as u64);
    }
}

#[inline]
fn u320_sub_u64(mut a: U320, b: u64) -> U320 {
    let (d, borrow) = a[0].overflowing_sub(b);
    a[0] = d;
    let mut c = borrow as u64;
    let mut i = 1;
    while c != 0 && i < 5 {
        let (di, bi) = a[i].overflowing_sub(c);
        a[i] = di;
        c = bi as u64;
        i += 1;
    }
    a
}

#[inline]
fn u320_add_mul_u64(mut acc: U320, x: &U320, factor: u64) -> Option<U320> {
    let f = factor as u128;
    let mut carry = 0u128;
    for i in 0..5 {
        let prod = (acc[i] as u128) + (x[i] as u128) * f + carry;
        acc[i] = prod as u64;
        carry = prod >> 64;
    }
    if carry != 0 || (acc[4] >> 62) != 0 {
        None
    } else {
        Some(acc)
    }
}

#[inline]
fn u320_double_mod(mut a: U320, m: &U320) -> U320 {
    let mut carry = 0u64;
    for i in 0..5 {
        let next = a[i] >> 63;
        a[i] = (a[i] << 1) | carry;
        carry = next;
    }
    if carry != 0 || u320_cmp(&a, m) != core::cmp::Ordering::Less {
        u320_sub_assign(&mut a, m);
    }
    a
}

#[inline]
fn u320_add_mod(mut a: U320, b: &U320, m: &U320) -> U320 {
    let mut carry = 0u64;
    for i in 0..5 {
        let sum = (a[i] as u128) + (b[i] as u128) + (carry as u128);
        a[i] = sum as u64;
        carry = (sum >> 64) as u64;
    }
    if carry != 0 || u320_cmp(&a, m) != core::cmp::Ordering::Less {
        u320_sub_assign(&mut a, m);
    }
    a
}

#[inline]
fn u320_mont_inv(p0: u64) -> u64 {
    let mut inv = 1u64;
    for _ in 0..5 {
        inv = inv.wrapping_mul(2u64.wrapping_sub(p0.wrapping_mul(inv)));
    }
    inv.wrapping_neg()
}

#[inline]
fn u320_mont_mul(a: &U320, b: &U320, p: &U320, n_prime: u64) -> U320 {
    let mut t = [0u64; 6];
    for i in 0..5 {
        let ai = a[i] as u128;
        let mut carry = 0u128;
        for j in 0..5 {
            let prod = ai * (b[j] as u128) + (t[j] as u128) + carry;
            t[j] = prod as u64;
            carry = prod >> 64;
        }
        let sum = (t[5] as u128) + carry;
        t[5] = sum as u64;

        let m = (t[0].wrapping_mul(n_prime)) as u128;
        let mut carry2 = ((t[0] as u128) + m * (p[0] as u128)) >> 64;
        for j in 1..5 {
            let prod = m * (p[j] as u128) + (t[j] as u128) + carry2;
            t[j - 1] = prod as u64;
            carry2 = prod >> 64;
        }
        let sum2 = (t[5] as u128) + carry2;
        t[4] = sum2 as u64;
        t[5] = (sum2 >> 64) as u64;
    }
    let mut out = [t[0], t[1], t[2], t[3], t[4]];
    if t[5] != 0 || u320_cmp(&out, p) != core::cmp::Ordering::Less {
        u320_sub_assign(&mut out, p);
    }
    out
}

#[inline]
fn u320_mont_one(p: &U320) -> U320 {
    let bits = u320_bitlen(p);
    let top = bits - 1;
    let mut r = [0u64; 5];
    r[top >> 6] = 1u64 << (top & 63);
    for _ in top..320 {
        r = u320_double_mod(r, p);
    }
    r
}

fn u320_is_probable_prime(p: &U320) -> bool {
    if p[1] == 0 && p[2] == 0 && p[3] == 0 && p[4] == 0 {
        return is_prime_u64(p[0]);
    }
    if (p[0] & 1) == 0 {
        return false;
    }
    let n_prime = u320_mont_inv(p[0]);
    let one_mont = u320_mont_one(p);
    let mut minus_one_mont = *p;
    u320_sub_assign(&mut minus_one_mont, &one_mont);

    // p == 1 (mod 4), so p - 1 = 2^s * d with s >= 2
    let mut pm1 = *p;
    pm1[0] &= !1u64;
    let mut s = 0usize;
    for i in 0..5 {
        if pm1[i] != 0 {
            s = i * 64 + (pm1[i].trailing_zeros() as usize);
            break;
        }
    }
    let d_top = u320_bitlen(&pm1) - 1;

    // Base-2 Miller-Rabin in Montgomery domain
    let base2_mont = u320_double_mod(one_mont, p);
    let mut x = base2_mont;
    for bit in (s..d_top).rev() {
        x = u320_mont_mul(&x, &x, p, n_prime);
        if u320_get_bit(&pm1, bit) {
            x = u320_mont_mul(&x, &base2_mont, p, n_prime);
        }
    }
    if x == one_mont || x == minus_one_mont {
        return true;
    }
    for _ in 1..s {
        x = u320_mont_mul(&x, &x, p, n_prime);
        if x == minus_one_mont {
            return true;
        }
        if x == one_mont {
            return false;
        }
    }
    false
}

#[inline]
fn u320_shl(a: &U320, shift: usize) -> U320 {
    if shift == 0 {
        return *a;
    }
    let word_shift = shift >> 6;
    let bit_shift = shift & 63;
    let mut out = [0u64; 5];
    for i in word_shift..5 {
        out[i] = a[i - word_shift] << bit_shift;
        if bit_shift > 0 && i > word_shift {
            out[i] |= a[i - word_shift - 1] >> (64 - bit_shift);
        }
    }
    out
}

#[inline]
fn u320_shr1(a: &mut U320) {
    for i in 0..4 {
        a[i] = (a[i] >> 1) | (a[i + 1] << 63);
    }
    a[4] >>= 1;
}

#[inline]
fn u320_rem(mut a: U320, b: &U320) -> U320 {
    let a_bits = u320_bitlen(&a);
    let b_bits = u320_bitlen(b);
    if a_bits < b_bits || b_bits == 0 {
        return a;
    }
    let shift = a_bits - b_bits;
    let mut d = u320_shl(b, shift);
    for _ in 0..=shift {
        if u320_cmp(&a, &d) != core::cmp::Ordering::Less {
            u320_sub_assign(&mut a, &d);
        }
        u320_shr1(&mut d);
    }
    a
}

#[inline]
fn u320_sq_gt(b: &U320, p: &U320) -> bool {
    let b_bits = u320_bitlen(b);
    let p_bits = u320_bitlen(p);
    if b_bits * 2 > p_bits + 1 {
        return true;
    }
    if b_bits * 2 < p_bits {
        return false;
    }
    let mut sq = [0u64; 5];
    for i in 0..5 {
        if b[i] == 0 {
            continue;
        }
        let bi = b[i] as u128;
        let mut carry = 0u128;
        for j in 0..5 {
            if i + j >= 5 {
                if b[j] != 0 || carry != 0 {
                    return true;
                }
                continue;
            }
            let prod = bi * (b[j] as u128) + (sq[i + j] as u128) + carry;
            sq[i + j] = prod as u64;
            carry = prod >> 64;
        }
        if carry != 0 {
            return true;
        }
    }
    u320_cmp(&sq, p) == core::cmp::Ordering::Greater
}

fn u320_cornacchia(p: &U320) -> Option<(BigUint, BigUint)> {
    if p[1] == 0 && p[2] == 0 && p[3] == 0 && p[4] == 0 {
        let (c, d) = cornacchia_u64(p[0])?;
        return Some((BigUint::from(c), BigUint::from(d)));
    }
    let n_prime = u320_mont_inv(p[0]);
    let one_mont = u320_mont_one(p);
    let mut minus_one_mont = *p;
    u320_sub_assign(&mut minus_one_mont, &one_mont);

    // exp = (p - 1) >> 2; since p == 1 (mod 4), exp = p >> 2
    let mut exp = [0u64; 5];
    for i in 0..4 {
        exp[i] = (p[i] >> 2) | (p[i + 1] << 62);
    }
    exp[4] = p[4] >> 2;
    let exp_bits = u320_bitlen(&exp);

    let mut base_mont = one_mont;
    let mut prev_g = 1u64;
    let mut z_mont = None;

    for &g in &NON_RESIDUE_BASES {
        for _ in prev_g..g {
            base_mont = u320_add_mod(base_mont, &one_mont, p);
        }
        prev_g = g;

        let mut x = base_mont;
        for bit in (0..exp_bits - 1).rev() {
            x = u320_mont_mul(&x, &x, p, n_prime);
            if u320_get_bit(&exp, bit) {
                x = u320_mont_mul(&x, &base_mont, p, n_prime);
            }
        }
        let sq = u320_mont_mul(&x, &x, p, n_prime);
        if sq == minus_one_mont {
            z_mont = Some(x);
            break;
        }
        // If sq^2 != 1 (mod p), p is composite!
        if sq != one_mont {
            return None;
        }
    }

    let z_m = z_mont?;
    let one_raw = [1u64, 0, 0, 0, 0];
    let z = u320_mont_mul(&z_m, &one_raw, p, n_prime);

    let mut a = *p;
    let mut b = z;
    while u320_sq_gt(&b, p) {
        let r = u320_rem(a, &b);
        a = b;
        b = r;
    }
    if u320_is_zero(&b) {
        return None;
    }
    let p_big = u320_to_biguint(p);
    let c_big = u320_to_biguint(&b);
    let rem = &p_big - &c_big * &c_big;
    let d_big = rem.sqrt();
    if &d_big * &d_big == rem {
        Some((c_big, d_big))
    } else {
        None
    }
}

// Pre-packed small prime chunks (each product < 2^62) to compute r1 % q_i and b0 % q_i with only 11 divisions
const PRIME_CHUNKS: [&[u32]; 11] = [
    &[3, 5, 7, 11, 13, 17, 19, 23, 29, 31, 37, 41, 43, 47],
    &[53, 59, 61, 67, 71, 73, 79, 83, 89, 97],
    &[101, 103, 107, 109, 113, 127, 131, 137, 139],
    &[149, 151, 157, 163, 167, 173, 179, 181],
    &[191, 193, 197, 199, 211, 223, 227, 229],
    &[233, 239, 241, 251, 257, 263, 269, 271],
    &[277, 281, 283, 293, 307, 311, 313],
    &[317, 331, 337, 347, 349, 353, 359],
    &[367, 373, 379, 383, 389, 397, 401],
    &[409, 419, 421, 431, 433, 439, 443],
    &[449, 457, 461, 463, 467, 479, 487, 491, 499, 503, 509],
];

fn compute_small_residues(x: &BigUint) -> [u32; 96] {
    let mut out = [0u32; 96];
    let mut idx = 0;
    for chunk in PRIME_CHUNKS.iter() {
        let mut prod = 1u128;
        for &q in *chunk {
            prod *= q as u128;
        }
        let rem_chunk: u128 = (x % prod).to_u128().unwrap_or(0);
        for &q in *chunk {
            out[idx] = (rem_chunk % (q as u128)) as u32;
            idx += 1;
        }
    }
    out
}

pub fn four_squares(n: BigInt) -> (BigInt, BigInt, BigInt, BigInt) {
    if n.sign() != Sign::Plus {
        return (
            BigInt::zero(),
            BigInt::zero(),
            BigInt::zero(),
            BigInt::zero(),
        );
    }
    let u = n.into_parts().1;
    let tz = u.trailing_zeros().unwrap_or(0);
    let shift = (tz >> 1) as usize;
    let m = &u >> (shift << 1);

    if m.bits() <= 128 {
        let val = m.to_u128().unwrap();
        let (a, b, c, d) = solve_u128(val);
        return (
            BigInt::from(a) << shift,
            BigInt::from(b) << shift,
            BigInt::from(c) << shift,
            BigInt::from(d) << shift,
        );
    }

    let s1 = m.sqrt();
    if &s1 * &s1 == m {
        return (
            BigInt::from_biguint(Sign::Plus, s1 << shift),
            BigInt::zero(),
            BigInt::zero(),
            BigInt::zero(),
        );
    }

    let rem4 = (m.iter_u32_digits().next().unwrap_or(0) & 3) as u8;
    let pa = if rem4 == 3 { 1u32 } else { 0u32 };
    let pb = if rem4 == 1 { 0u32 } else { 1u32 };

    let s1_parity = (s1.iter_u32_digits().next().unwrap_or(0) & 1) as u32;
    let mut a = if s1_parity == pa {
        s1
    } else {
        &s1 - BigUint::one()
    };

    let two = BigUint::from(2u32);

    loop {
        let r1 = &m - &a * &a;
        if r1.bits() <= 128 {
            let r1_u128 = r1.to_u128().unwrap();
            let s2 = isqrt_u128(r1_u128);
            if s2 * s2 == r1_u128 {
                return (
                    BigInt::from_biguint(Sign::Plus, &a << shift),
                    BigInt::from_biguint(Sign::Plus, BigUint::from(s2) << shift),
                    BigInt::zero(),
                    BigInt::zero(),
                );
            }
            let mut b = if ((s2 as u32) & 1) == pb {
                s2
            } else {
                s2.wrapping_sub(1)
            };
            while b <= s2 {
                let p128 = r1_u128 - b * b;
                if p128 == 1 {
                    return (
                        BigInt::from_biguint(Sign::Plus, &a << shift),
                        BigInt::from_biguint(Sign::Plus, BigUint::from(b) << shift),
                        BigInt::from_biguint(Sign::Plus, BigUint::one() << shift),
                        BigInt::zero(),
                    );
                }
                if p128 <= u64::MAX as u128 && is_prime_u64(p128 as u64) {
                    if let Some((c, d)) = cornacchia_u64(p128 as u64) {
                        return (
                            BigInt::from_biguint(Sign::Plus, &a << shift),
                            BigInt::from_biguint(Sign::Plus, BigUint::from(b) << shift),
                            BigInt::from_biguint(Sign::Plus, BigUint::from(c) << shift),
                            BigInt::from_biguint(Sign::Plus, BigUint::from(d) << shift),
                        );
                    }
                }
                if b < 2 {
                    break;
                }
                b -= 2;
            }
            a -= &two;
            continue;
        }

        let s2 = r1.sqrt();
        if &s2 * &s2 == r1 {
            return (
                BigInt::from_biguint(Sign::Plus, a << shift),
                BigInt::from_biguint(Sign::Plus, s2 << shift),
                BigInt::zero(),
                BigInt::zero(),
            );
        }

        let s2_parity = (s2.iter_u32_digits().next().unwrap_or(0) & 1) as u32;
        let b0 = if s2_parity == pb {
            s2
        } else {
            &s2 - BigUint::one()
        };

        let p0 = &r1 - &b0 * &b0;
        let r1_mods = compute_small_residues(&r1);
        let b0_mods = compute_small_residues(&b0);

        if let (Some(b0_u320), Some(p0_u320)) = (biguint_to_u320(&b0), biguint_to_u320(&p0)) {
            let p0_gt_u64 = (p0_u320[1] | p0_u320[2] | p0_u320[3] | p0_u320[4]) != 0;
            for k in 0..512u32 {
                let two_k = k << 1;
                if p0_gt_u64 || k > 0 {
                    let mut divisible = false;
                    for i in 0..SMALL_PRIMES.len() {
                        let q = SMALL_PRIMES[i];
                        let b_mod = (b0_mods[i] + q - (two_k % q)) % q;
                        if (b_mod * b_mod) % q == r1_mods[i] {
                            divisible = true;
                            break;
                        }
                    }
                    if divisible {
                        continue;
                    }
                }

                let b_minus_k = u320_sub_u64(b0_u320, k as u64);
                let p_u320 = match u320_add_mul_u64(p0_u320, &b_minus_k, (k as u64) << 2) {
                    Some(v) => v,
                    None => break,
                };

                if p_u320 == [1, 0, 0, 0, 0] {
                    let b_final = &b0 - BigUint::from(two_k);
                    return (
                        BigInt::from_biguint(Sign::Plus, a << shift),
                        BigInt::from_biguint(Sign::Plus, b_final << shift),
                        BigInt::from_biguint(Sign::Plus, BigUint::one() << shift),
                        BigInt::zero(),
                    );
                }

                if u320_is_probable_prime(&p_u320) {
                    if let Some((c, d)) = u320_cornacchia(&p_u320) {
                        let b_final = &b0 - BigUint::from(two_k);
                        return (
                            BigInt::from_biguint(Sign::Plus, a << shift),
                            BigInt::from_biguint(Sign::Plus, b_final << shift),
                            BigInt::from_biguint(Sign::Plus, c << shift),
                            BigInt::from_biguint(Sign::Plus, d << shift),
                        );
                    }
                }
            }
        }

        a -= &two;
    }
}

