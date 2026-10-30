# Express number as sum of four squares (Rust)

**Kyu:** 1 · **Source:** [Codewars](https://www.codewars.com/kata/63022799acfb8d00285b4ea0/train/rust) · **ID:** `63022799acfb8d00285b4ea0`
(Rust, by `dolamroth`)

Given a non-negative integer $N$ up to $2^{1024}$, compute four integers $(a, b, c, d)$ such that:

$$N = a^2 + b^2 + c^2 + d^2$$

## Solution (`ultra-omni-upz` Double-Sqrt Cascade + Stack `U320` Montgomery Engine)

Standard Rabin–Shallit / Pollack–Treviño implementations subtract a single 512-bit square $a^2$ (or random $(a, b)$) and run Miller–Rabin + Cornacchia on **1024-bit** `BigUint`s, which bottlenecks on heap allocations and software long division in `num-bigint 0.4`.

Our implementation collapses the bit width twice before touching primality testing:

1. **Power-of-4 Normalization & Parity Alignment**:
   - Strip $4^{\text{shift}} \parallel N$ via trailing zeros so $m = N / 4^{\text{shift}} \not\equiv 0 \pmod 4$.
   - Choose parities $(p_a, p_b)$ according to $m \bmod 4$:
     - $m \equiv 1 \pmod 4 \implies (a \text{ even}, b \text{ even})$
     - $m \equiv 2 \pmod 4 \implies (a \text{ even}, b \text{ odd})$
     - $m \equiv 3 \pmod 4 \implies (a \text{ odd}, b \text{ odd})$
   - This guarantees $p = m - a^2 - b^2 \equiv 1 \pmod 4$ for every candidate $(a, b)$, completely avoiding Legendre's $8k+7$ three-square obstruction.

2. **Double-Sqrt Bit-Width Cascade ($1024\text{b} \to 513\text{b} \to 258\text{b}$)**:
   - First square: $a \approx \lfloor \sqrt{m} \rfloor$ ($512$ bits) $\implies r_1 = m - a^2 < 4\sqrt{m}$ has at most **~514 bits**.
   - Second square: $b_0 \approx \lfloor \sqrt{r_1} \rfloor$ ($257$ bits) $\implies p(k) = r_1 - (b_0 - 2k)^2 = p_0 + 4k(b_0 - k)$ has at most **~258–266 bits**, fitting inside a 5-limb stack array `U320 = [u64; 5]`.

3. **Zero-Allocation `u32` Residue Sieve + Stack `U320` CIOS Montgomery + Cornacchia**:
   - Pre-reduces $r_1 \bmod q_i$ and $b_0 \bmod q_i$ across the first 96 odd primes ($3 \dots 509$) packed into 11 `u128` chunks, rejecting ~85% of $k$ steps in pure `u32` arithmetic without computing $b^2$.
   - Surviving candidates are evaluated in stack-allocated `U320` (`[u64; 5]`, $R = 2^{320}$) via CIOS Montgomery Miller–Rabin and Montgomery Cornacchia ($z = g^{(p-1)/4} \bmod p$ + telescoping shift-subtract Euclidean half-GCD), solving all 20 $\times 2^{128}$ + 20 $\times 2^{1024}$ random tests in **~7.2 ms** total.

## Files

- `solution.rs` — Double-sqrt cascade + stack `U320` CIOS Montgomery + Cornacchia implementation
- `Cargo.toml` — Rust crate configuration (`num = "0.4"`)
- `test_solution.py` — test runner invoking `cargo test --release`
- `bluesky-receipt.json` — published 4-post ELI5 educational Bluesky thread ([Root: `3mz3wsnro7q22`](https://bsky.app/profile/0xp3t3rl.bsky.social/post/3mz3wsnro7q22))
