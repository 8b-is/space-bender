#include <cassert>
#include <cstring>
#include <iostream>
#include <string>
#include <vector>

extern "C" std::size_t blox_solver_asm(const char *grid_str, char *out_moves);

struct Pose {
    int o, r, c;
};

static bool verify_solution(const std::vector<std::string> &grid, const std::string &moves, std::size_t expected_len) {
    if (moves.size() != expected_len) return false;
    int h = static_cast<int>(grid.size());
    int w = static_cast<int>(grid[0].size());
    int sr = -1, sc = -1, xr = -1, xc = -1;
    for (int r = 0; r < h; ++r) {
        for (int c = 0; c < w; ++c) {
            if (grid[r][c] == 'B') { sr = r; sc = c; }
            if (grid[r][c] == 'X') { xr = r; xc = c; }
        }
    }
    auto at = [&](int r, int c) {
        return r >= 0 && r < h && c >= 0 && c < w && grid[r][c] != '0';
    };
    Pose p{0, sr, sc};
    for (char m : moves) {
        if (p.o == 0) {
            if (m == 'U') p = {2, p.r - 2, p.c};
            else if (m == 'D') p = {2, p.r + 1, p.c};
            else if (m == 'L') p = {1, p.r, p.c - 2};
            else if (m == 'R') p = {1, p.r, p.c + 1};
            else return false;
        } else if (p.o == 1) {
            if (m == 'U') p = {1, p.r - 1, p.c};
            else if (m == 'D') p = {1, p.r + 1, p.c};
            else if (m == 'L') p = {0, p.r, p.c - 1};
            else if (m == 'R') p = {0, p.r, p.c + 2};
            else return false;
        } else {
            if (m == 'U') p = {0, p.r - 1, p.c};
            else if (m == 'D') p = {0, p.r + 2, p.c};
            else if (m == 'L') p = {2, p.r, p.c - 1};
            else if (m == 'R') p = {2, p.r, p.c + 1};
            else return false;
        }
        if (p.o == 0 && !at(p.r, p.c)) return false;
        if (p.o == 1 && (!at(p.r, p.c) || !at(p.r, p.c + 1))) return false;
        if (p.o == 2 && (!at(p.r, p.c) || !at(p.r + 1, p.c))) return false;
    }
    return p.o == 0 && p.r == xr && p.c == xc;
}

int main() {
    struct TestCase {
        std::vector<std::string> grid;
        std::size_t expected_len;
    };
    std::vector<TestCase> cases = {
        {{
            "1110000000",
            "1B11110000",
            "1111111110",
            "0111111111",
            "0000011X11",
            "0000001110"
        }, 7},
        {{
            "0000001111111000",
            "1111001111011000",
            "1111111111011111",
            "1B11000000011X11",
            "1111000000011111",
            "0000000000001110"
        }, 14},
        {{
            "000001X11",
            "B11111111",
            "000011100",
            "000011100"
        }, 7},
        {{
            "00001110000000000000",
            "00001111111100000000",
            "00001000001100000000",
            "01111111001100000000",
            "01B10011101100000000",
            "01100011111110000000",
            "01100011111110000000",
            "00000000000011100000",
            "00000000000011100000",
            "00001111111111111000",
            "01111101110000000000",
            "01101111110011111111",
            "011111001111111011X1",
            "01100000011101001111"
        }, 29}
    };

    char out_buf[512];
    for (const auto &tc : cases) {
        std::string joined;
        for (std::size_t i = 0; i < tc.grid.size(); ++i) {
            joined += tc.grid[i];
            if (i + 1 < tc.grid.size()) joined += '\n';
        }
        std::size_t len = blox_solver_asm(joined.c_str(), out_buf);
        std::string moves(out_buf, len);
        assert(verify_solution(tc.grid, moves, tc.expected_len));
    }
    std::cout << "ALL AARCH64 + NASM BLOXORZ SUITES PASSED!" << std::endl;
    return 0;
}
