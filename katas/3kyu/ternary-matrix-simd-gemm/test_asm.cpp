#include <cassert>
#include <cstdint>
#include <cstdio>
#include <vector>

extern "C" int32_t ternary_dot_neon_i16(const int16_t *acts, const int8_t *trits, size_t len);

static int32_t ref_dot(const int16_t *acts, const int8_t *trits, size_t len) {
    int32_t acc = 0;
    for (size_t i = 0; i < len; ++i) {
        acc += static_cast<int32_t>(acts[i]) * static_cast<int32_t>(trits[i]);
    }
    return acc;
}

int main() {
    std::vector<int16_t> acts(128);
    std::vector<int8_t> trits(128);
    for (size_t i = 0; i < 128; ++i) {
        acts[i] = static_cast<int16_t>((static_cast<int>(i) * 73) - 2048);
        trits[i] = (i % 3 == 0) ? 1 : ((i % 3 == 1) ? -1 : 0);
    }

    for (size_t len = 1; len <= 128; ++len) {
        int32_t expected = ref_dot(acts.data(), trits.data(), len);
        int32_t actual = ternary_dot_neon_i16(acts.data(), trits.data(), len);
        assert(actual == expected);
    }

    std::puts("ALL AARCH64 NEON TERNARY_DOT_SIMD SUITES PASSED!");
    return 0;
}
