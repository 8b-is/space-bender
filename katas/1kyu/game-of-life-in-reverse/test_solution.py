#!/usr/bin/env python3
"""Verification suite for Game of Life in Reverse (1 kyu, Factor, 5ea6a8502186ab001427809e)."""

import json
import os
import random
import shutil
import subprocess
import time
from pathlib import Path

HERE = Path(__file__).resolve().parent
SOLUTION = HERE / "solution.factor"


def find_factor_bin() -> str:
    for candidate in ("/Applications/factor/factor", shutil.which("factor-vm") or ""):
        if candidate and os.path.isfile(candidate) and os.access(candidate, os.X_OK):
            return candidate
    raise RuntimeError("Factor binary not found at /Applications/factor/factor")


def step_life(grid: list[list[int]]) -> list[list[int]]:
    h, w = len(grid), len(grid[0])
    out = [[0] * w for _ in range(h)]
    for r in range(h):
        for c in range(w):
            cnt = 0
            for dr in (-1, 0, 1):
                for dc in (-1, 0, 1):
                    if (dr or dc) and 0 <= r + dr < h and 0 <= c + dc < w:
                        cnt += grid[r + dr][c + dc]
            if grid[r][c]:
                out[r][c] = 1 if cnt in (2, 3) else 0
            else:
                out[r][c] = 1 if cnt == 3 else 0
    return out


def pad_goal(goal: list[list[int]]) -> list[list[int]]:
    w = len(goal[0]) + 2
    return [[0] * w] + [[0] + row + [0] for row in goal] + [[0] * w]


def to_factor_grid(goal: list[list[int]]) -> str:
    rows = ["{ " + " ".join(str(x) for x in row) + " }" for row in goal]
    return "{ " + " ".join(rows) + " }"


def main() -> None:
    factor_bin = find_factor_bin()

    # Build test cases: fixed examples + classic patterns + 50 random grids + Garden of Eden
    solvable_goals: list[list[list[int]]] = [
        # Example 1
        [[0, 0, 1, 1, 0], [1, 1, 1, 1, 0], [0, 0, 1, 1, 1]],
        # Example 2
        [[0, 0, 0, 0], [0, 1, 1, 0], [0, 1, 1, 0], [0, 0, 0, 0]],
        # Glider
        [[0, 1, 0, 0], [0, 0, 1, 0], [1, 1, 1, 0], [0, 0, 0, 0]],
        # All-1s 6x6 and 7x7
        [[1] * 6 for _ in range(6)],
        [[1] * 7 for _ in range(7)],
    ]

    rng = random.Random(42)
    for _ in range(50):
        m, n = rng.randint(2, 7), rng.randint(2, 7)
        solvable_goals.append(
            [[1 if rng.random() < 0.35 else 0 for _ in range(n)] for _ in range(m)]
        )

    unsolvable_goals: list[list[list[int]]] = [
        [[1, 0, 0, 1, 0], [1, 1, 1, 0, 0], [0, 1, 1, 1, 0], [1, 0, 1, 1, 1], [1, 1, 1, 1, 0]],
    ]

    # Generate a single Factor batch script that evaluates all test cases and outputs JSON lines
    lines = [
        "IN: reverse-life",
        "USE: io USE: json",
    ]
    for g in solvable_goals + unsolvable_goals:
        lines.append(f"{to_factor_grid(g)} find-predecessor >json print")

    batch_code = "\n".join(lines)
    wrapper = (
        "USING: io.files parser ;\n"
        f"{json.dumps(str(SOLUTION))} parse-file call( -- )\n"
        f"{json.dumps(batch_code)} eval( -- )\n"
    )

    t0 = time.perf_counter()
    proc = subprocess.run(
        [factor_bin, f"-e={wrapper}"],
        capture_output=True,
        text=True,
        check=True,
    )
    elapsed_ms = (time.perf_counter() - t0) * 1000.0

    outputs = [line.strip() for line in proc.stdout.strip().splitlines() if line.strip()]
    expected_total = len(solvable_goals) + len(unsolvable_goals)
    assert len(outputs) == expected_total, f"Expected {expected_total} outputs, got {len(outputs)}"

    for i, g in enumerate(solvable_goals):
        pred = json.loads(outputs[i])
        assert pred and isinstance(pred, list), f"Expected valid predecessor for solvable test {i}, got {pred}"
        assert len(pred) == len(g) + 2 and len(pred[0]) == len(g[0]) + 2
        nxt = step_life(pred)
        expected = pad_goal(g)
        assert nxt == expected, f"Successor mismatch at solvable test {i}"

    for j, g in enumerate(unsolvable_goals):
        idx = len(solvable_goals) + j
        pred = json.loads(outputs[idx])
        assert pred is False, f"Expected f (false) for Garden of Eden test {j}, got {pred}"

    print(
        f"ALL PASS ({len(solvable_goals)} solvable + {len(unsolvable_goals)} Garden of Eden "
        f"Factor tests verified in {elapsed_ms:.1f} ms)"
    )


if __name__ == "__main__":
    main()
