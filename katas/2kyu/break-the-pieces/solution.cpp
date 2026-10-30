// Codewars 2 kyu — Break the pieces
// ID: 527fde8d24b9309d9b000c4e

#include <algorithm>
#include <queue>
#include <sstream>
#include <string>
#include <utility>
#include <vector>

std::vector<std::string> break_piece(const std::string &shape) {
    std::vector<std::string> lines;
    std::stringstream ss(shape);
    std::string line;
    std::size_t max_w = 0;

    while (std::getline(ss, line)) {
        if (!line.empty() && line.back() == '\r') {
            line.pop_back();
        }
        max_w = std::max(max_w, line.size());
        lines.push_back(std::move(line));
    }

    if (lines.empty() || max_w == 0) {
        return {};
    }

    const int H = static_cast<int>(lines.size()) + 2;
    const int W = static_cast<int>(max_w) + 2;
    std::vector<std::string> grid(H, std::string(W, ' '));

    for (std::size_t r = 0; r < lines.size(); ++r) {
        for (std::size_t c = 0; c < lines[r].size(); ++c) {
            grid[r + 1][c + 1] = lines[r][c];
        }
    }

    std::vector<std::vector<bool>> visited(H, std::vector<bool>(W, false));
    constexpr int DR4[4] = {-1, 1, 0, 0};
    constexpr int DC4[4] = {0, 0, -1, 1};

    auto bfs_spaces = [&](int sr, int sc) {
        std::vector<std::pair<int, int>> comp;
        std::queue<std::pair<int, int>> q;
        visited[sr][sc] = true;
        q.push({sr, sc});

        while (!q.empty()) {
            auto [r, c] = q.front();
            q.pop();
            comp.push_back({r, c});
            for (int d = 0; d < 4; ++d) {
                int nr = r + DR4[d];
                int nc = c + DC4[d];
                if (nr >= 0 && nr < H && nc >= 0 && nc < W &&
                    !visited[nr][nc] && grid[nr][nc] == ' ') {
                    visited[nr][nc] = true;
                    q.push({nr, nc});
                }
            }
        }
        return comp;
    };

    // Flood-fill the exterior background starting from (0, 0)
    bfs_spaces(0, 0);

    std::vector<std::string> pieces;
    std::vector<std::vector<int>> bnd_stamp(H, std::vector<int>(W, 0));
    int stamp_id = 0;

    for (int r = 1; r < H - 1; ++r) {
        for (int c = 1; c < W - 1; ++c) {
            if (grid[r][c] == ' ' && !visited[r][c]) {
                auto sp = bfs_spaces(r, c);
                ++stamp_id;

                std::vector<std::pair<int, int>> bnd;
                int min_r = H, max_r = 0, min_c = W, max_c = 0;

                for (auto [sr, sc] : sp) {
                    for (int dr = -1; dr <= 1; ++dr) {
                        for (int dc = -1; dc <= 1; ++dc) {
                            int nr = sr + dr;
                            int nc = sc + dc;
                            if (grid[nr][nc] != ' ' && bnd_stamp[nr][nc] != stamp_id) {
                                bnd_stamp[nr][nc] = stamp_id;
                                bnd.push_back({nr, nc});
                                min_r = std::min(min_r, nr);
                                max_r = std::max(max_r, nr);
                                min_c = std::min(min_c, nc);
                                max_c = std::max(max_c, nc);
                            }
                        }
                    }
                }

                std::vector<std::string> canvas(
                    max_r - min_r + 1, std::string(max_c - min_c + 1, ' '));

                for (auto [br, bc] : bnd) {
                    bool has_h = (bnd_stamp[br][bc - 1] == stamp_id) ||
                                 (bnd_stamp[br][bc + 1] == stamp_id);
                    bool has_v = (bnd_stamp[br - 1][bc] == stamp_id) ||
                                 (bnd_stamp[br + 1][bc] == stamp_id);
                    canvas[br - min_r][bc - min_c] =
                        (has_h && has_v) ? '+' : (has_h ? '-' : '|');
                }

                std::string piece;
                for (std::size_t i = 0; i < canvas.size(); ++i) {
                    while (!canvas[i].empty() && canvas[i].back() == ' ') {
                        canvas[i].pop_back();
                    }
                    piece += canvas[i];
                    if (i + 1 < canvas.size()) {
                        piece += '\n';
                    }
                }
                pieces.push_back(std::move(piece));
            }
        }
    }

    return pieces;
}
