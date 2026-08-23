"""Prime Streaming (NC-17) — segmented sieve of Eratosthenes.

Infinite segmented sieve with C-level hot paths:
- marking via bytearray slice-assignment,
- collection via precompiled regex finditer over a memoryview (no copy).
Base primes bootstrapped to ~1M and grown as segments advance.
"""

from math import isqrt
import re

_FIND = re.compile(b"\x01")


def primes():
    yield 2
    yield 3
    yield 5
    yield 7
    yield 11
    yield 13
    yield 17
    yield 19
    yield 23
    yield 29
    yield 31
    yield 37

    SEG = 1 << 21  # 2,097,152 — segment length (odd count = SEG/2)
    low = 41
    high = low + SEG

    # bootstrap base primes up to ~1M (78k primes)
    BOOT = 1 << 20
    size = (BOOT - 3) // 2 + 1
    s = bytearray(b"\x01") * size
    for i in range(size):
        if s[i]:
            p = 3 + 2 * i
            if p * p > BOOT:
                break
            start = (p * p - 3) // 2
            s[start::p] = b"\x00" * (((size - 1 - start) // p) + 1)
    base = [3 + 2 * i for i in range(size) if s[i]]

    while True:
        size = SEG // 2
        sieve = bytearray(b"\x01") * size
        limit = isqrt(high - 1)
        for p in base:
            if p > limit:
                break
            start = low + ((p - (low % p)) % p)
            if start < p * p:
                start = p * p
            if start % 2 == 0:
                start += p
            j = (start - low) // 2
            if j < size:
                sieve[j::p] = b"\x00" * (((size - 1 - j) // p) + 1)
        new_base = []
        mv = memoryview(sieve)
        for m in _FIND.finditer(mv):
            n = low + 2 * m.start()
            yield n
            if n <= limit and n > base[-1]:
                new_base.append(n)
        base.extend(new_base)
        low = high
        high = low + SEG
