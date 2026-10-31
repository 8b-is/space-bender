#include "solution.cpp"
#include <algorithm>
#include <cassert>
#include <iostream>

extern "C" std::size_t break_piece_asm(const char *shape, const char **out_pieces);

static void assert_pieces_eq(const std::string &shape, const std::vector<std::string> &expected) {
    auto got_cpp = break_piece(shape);
    auto exp_sorted = expected;
    std::sort(got_cpp.begin(), got_cpp.end());
    std::sort(exp_sorted.begin(), exp_sorted.end());
    if (got_cpp != exp_sorted) {
        std::cerr << "C++ MISMATCH!\n";
        assert(false);
    }

    const char *raw_pieces[128];
    std::size_t n_asm = break_piece_asm(shape.c_str(), raw_pieces);
    std::vector<std::string> got_asm(raw_pieces, raw_pieces + n_asm);
    std::sort(got_asm.begin(), got_asm.end());
    if (got_asm != exp_sorted) {
        std::cerr << "ASM MISMATCH!\nGot (" << got_asm.size() << "):\n";
        for (const auto &s : got_asm) std::cerr << "---\n" << s << "\n";
        std::cerr << "Expected (" << exp_sorted.size() << "):\n";
        for (const auto &s : exp_sorted) std::cerr << "---\n" << s << "\n";
        assert(false);
    }
}

int main() {
    // 1. Classic 3-piece example from description
    {
        std::string shape =
            "+------------+\n"
            "|            |\n"
            "|            |\n"
            "|            |\n"
            "+------+-----+\n"
            "|      |     |\n"
            "|      |     |\n"
            "+------+-----+";
        std::vector<std::string> expected = {
            "+------------+\n"
            "|            |\n"
            "|            |\n"
            "|            |\n"
            "+------------+",
            "+------+\n"
            "|      |\n"
            "|      |\n"
            "+------+",
            "+-----+\n"
            "|     |\n"
            "|     |\n"
            "+-----+"
        };
        assert_pieces_eq(shape, expected);
    }

    // 2. Non-rectangular L-shape with leading spaces
    {
        std::string shape =
            "    +---+\n"
            "    |   |\n"
            "+---+   |\n"
            "|       |\n"
            "+-------+";
        std::vector<std::string> expected = {shape};
        assert_pieces_eq(shape, expected);
    }

    // 3. Interlocking L-shapes
    {
        std::string shape =
            "+-------------------+--+\n"
            "|                   |  |\n"
            "|                   |  |\n"
            "|  +----------------+  |\n"
            "|  |                   |\n"
            "|  |                   |\n"
            "+--+-------------------+";
        std::vector<std::string> expected = {
            "                 +--+\n"
            "                 |  |\n"
            "                 |  |\n"
            "+----------------+  |\n"
            "|                   |\n"
            "|                   |\n"
            "+-------------------+",
            "+-------------------+\n"
            "|                   |\n"
            "|                   |\n"
            "|  +----------------+\n"
            "|  |\n"
            "|  |\n"
            "+--+"
        };
        assert_pieces_eq(shape, expected);
    }

    // 4. Complex nested donut / window shape from Codewars test suite
    {
        std::string shape =
            "+---------+--+   +--+-+ +-----+\n"
            "|         |  |   |  | | |     |\n"
            "|  +---+  |  +---+  | | | +-+ |\n"
            "|  |   |  |         | | | | | |\n"
            "|  +---+  |  +---+  | | +-+ | |\n"
            "|  |   |  |  |   |  | |     | |\n"
            "|  +---+  |  +---+  | +-----+ |\n"
            "|         |         |         |\n"
            "+---------+---------+---------+";
        std::vector<std::string> expected = {
            "+-+ +-----+\n"
            "| | |     |\n"
            "| | | +-+ |\n"
            "| | | | | |\n"
            "| | +-+ | |\n"
            "| |     | |\n"
            "| +-----+ |\n"
            "|         |\n"
            "+---------+",
            "+--+   +--+\n"
            "|  |   |  |\n"
            "|  +---+  |\n"
            "|         |\n"
            "|  +---+  |\n"
            "|  |   |  |\n"
            "|  +---+  |\n"
            "|         |\n"
            "+---------+",
            "+---+\n"
            "|   |\n"
            "+---+",
            "+---+\n"
            "|   |\n"
            "+---+",
            "+---+\n"
            "|   |\n"
            "+---+",
            "+---------+\n"
            "|         |\n"
            "|  +---+  |\n"
            "|  |   |  |\n"
            "|  |   |  |\n"
            "|  |   |  |\n"
            "|  +---+  |\n"
            "|         |\n"
            "+---------+"
        };
        assert_pieces_eq(shape, expected);
    }

    std::cout << "ALL 4 BREAK_THE_PIECES SUITES PASSED (C++20 + x86-64 NASM)!" << std::endl;
    return 0;
}
