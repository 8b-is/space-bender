# Prime Streaming (NC-17) (2 kyu)

**Kyu:** 2 · **Source:** [Codewars](https://www.codewars.com/kata/59122604e5bc240817000016)
— stream the prime numbers endlessly.

## Solution

**Segmented sieve of Eratosthenes** with C-level hot paths:

- base primes bootstrapped to ~1M with a bytearray sieve marked via
  slice-assignment (`s[start::p] = b"\x00" * …`),
- then infinite 2M-wide segments over the odd numbers only,
- collection via a precompiled regex `finditer` over a `memoryview` of
  the segment (no copy), newly found small primes extending the base
  list as the sieve advances.

Exposes `primes()` as a generator yielding primes as ints (the local
API this solution ships; the platform variant wraps it in a `PG` class
yielding strings).

## Verified

`test_solution.py` — first 12 primes exact, first 200 cross-checked for
primality + strict monotonicity by trial division, 1000th prime = 7919,
10000th prime = 104729, independent streams restart at 2.
`ALL TESTS PASS`.

## Files

- `solution.py` — the solution
- `test_solution.py` — verification suite
