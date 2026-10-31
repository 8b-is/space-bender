#include <cassert>
#include <cstdint>
#include <iostream>
#include <string>
#include <vector>

extern "C" std::size_t range_extraction_asm(const std::int64_t *arr, std::size_t n, char *out_buf);

int main() {
    struct Case {
        std::vector<std::int64_t> arr;
        std::string expected;
    };
    std::vector<Case> cases = {
        {{-6, -3, -2, -1, 0, 1, 3, 4, 5, 7, 8, 9, 10, 11, 14, 15, 17, 18, 19, 20},
         "-6,-3-1,3-5,7-11,14,15,17-20"},
        {{-10, -9, -8, -6, -3, -2, -1, 0, 1, 3, 4, 5, 7, 8, 9, 10, 11, 14, 15, 17, 18, 19, 20},
         "-10--8,-6,-3-1,3-5,7-11,14,15,17-20"},
        {{-3, -2, -1, 2, 10, 15, 16, 18, 19, 20},
         "-3--1,2,10,15,16,18-20"},
        {{1, 2, 3, 4, 5}, "1-5"},
        {{1, 2, 4, 5}, "1,2,4,5"},
        {{42}, "42"},
        {{}, ""}
    };

    char buf[1024];
    for (const auto &c : cases) {
        std::size_t len = range_extraction_asm(c.arr.data(), c.arr.size(), buf);
        std::string got(buf, len);
        assert(got == c.expected);
    }
    std::cout << "ALL AARCH64 + NASM RANGE_EXTRACTION SUITES PASSED!" << std::endl;
    return 0;
}
