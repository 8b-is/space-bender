# Break the pieces (2 kyu — C++)

- **Codewars Kata**: [Break the pieces](https://www.codewars.com/kata/527fde8d24b9309d9b000c4e/cpp)
- **ID**: `527fde8d24b9309d9b000c4e`
- **Language**: C++ (`std::vector<std::string> break_piece(const std::string &shape)`)

## Overview

Decomposes an ASCII box diagram (`+`, `-`, `|`, `' '`) into its minimal closed pieces, smoothing away T-junctions (`+` $\to$ `-` or `|`) that belonged only to adjacent pieces and trimming trailing spaces on every line.

## Algorithm

1. **Exterior Flood-Fill**:
   - Pads the diagram with a 1-cell border of `' '` and runs a 4-connected BFS from `(0, 0)` to mark all background spaces.
2. **Interior Component & 8-Neighbor Boundary Extraction**:
   - Each remaining unvisited `' '` component `sp` is a minimal closed piece.
   - Its boundary `bnd` consists of all non-space cells in the 8-neighborhood of `sp` (tracked in $O(1)$ with a monotonic `stamp_id` grid `bnd_stamp`).
3. **Corner Smoothing**:
   - A boundary cell `(r, c)` is rendered as `'+'` iff it has both a horizontal neighbor (`(r, c-1)` or `(r, c+1)`) and a vertical neighbor (`(r-1, c)` or `(r+1, c)`) in `bnd`; otherwise it simplifies to `'-'` or `'|'`.
