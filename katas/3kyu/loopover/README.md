# Loopover

**Kyu:** 3 · **Source:** Codewars

A sliding puzzle where the entire grid is filled and rows/columns wrap
around. Moves: `R0`/`L0` (rotate row right/left), `U0`/`D0` (rotate column
up/down). Return a list of moves to transform the mixed board into the
solved board, or `None` for unsolvable configurations.

## Solution

Recursive fix-the-first-misplaced-cell with **local 3-cycles** that never
disturb already-solved cells:

- `swap_adj(coord)` — swaps a cell with the one to its right (plus the
  mirror cells in the previous row), a pure local cycle.
- `three_slip(coord)` — moves a cell two places right (`ABC → BCA`) using
  the row above as a buffer, composed from `swap_adj` cycles.
- `final_swap(rows, columns)` — handles the last-row, second-to-last-column
  corner; returns `None` (unsolvable) when the columns dimension is odd.
- **Parity**: if there is an even dimension it is made the columns (via
  transpose) so the odd-parity case is always detectable.
- **Degenerate boards**: single-row (only R/L) and single-column (only U/D)
  boards are solved by direct rotation matching.

Verified exhaustively: 540 random boards across 18 sizes (2x2 .. 7x3,
including 1xN and Nx1), all solved; odd-parity 3x3 correctly returns None.

## Files

- `solution.py` — the solver
- `test_solution.py` — exhaustive verification
