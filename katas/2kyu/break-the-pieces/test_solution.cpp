#include "solution.cpp"
#include <algorithm>
#include <cassert>
#include <iostream>

static void assert_pieces_eq(std::vector<std::string> got, std::vector<std::string> expected) {
    std::sort(got.begin(), got.end());
    std::sort(expected.begin(), expected.end());
    if (got != expected) {
        std::cerr << "MISMATCH!\nGot (" << got.size() << "):\n";
        for (const auto &s : got) std::cerr << "---\n" << s << "\n";
        std::cerr << "Expected (" << expected.size() << "):\n";
        for (const auto &s : expected) std::cerr << "---\n" << s << "\n";
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
        assert_pieces_eq(break_piece(shape), expected);
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
        assert_pieces_eq(break_piece(shape), expected);
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
        assert_pieces_eq(break_piece(shape), expected);
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
        assert_pieces_eq(break_piece(shape), expected);
    }

    std::cout << "ALL 4 BREAK_THE_PIECES SUITES PASSED!" << std::endl;
    return 0;
}
