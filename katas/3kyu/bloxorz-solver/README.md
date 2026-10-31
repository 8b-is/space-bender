# Bloxorz Solver (3 kyu — Haskell + x86-64 NASM + AArch64 Assembly)

- **Codewars Kata**: [Bloxorz Solver](https://www.codewars.com/kata/5a2a597a8882f392020005e5/haskell)
- **ID**: `5a2a597a8882f392020005e5`
- **Languages**: Haskell (`solution.hs`), x86-64 NASM (`solution.asm`), Apple Silicon AArch64 (`solution_arm64.s`)

## Overview

Finds the shortest sequence of moves (`U`, `D`, `L`, `R`) to roll a $1 \times 1 \times 2$ rectangular cuboid from upright on `B` to upright on the destination square hole `X` without ever exposing any part of its bottom face to open air (`0`).

## Architecture

1. **Haskell (`solution.hs`)**:
   - Models the cuboid state as `data Pose = Upright !Int !Int | Horz !Int !Int | Vert !Int !Int`.
   - Uses `Data.Sequence.Seq` for $O(1)$ amortized FIFO queue operations and `Data.Set.Set Pose` for visited-state deduplication.
2. **x86-64 NASM (`solution.asm`) & AArch64 (`solution_arm64.s`)**:
   - Embeds the board at offset `(r + 2, c + 2)` inside a $32 \times 32$ zero-moat grid (`idx = (r << 5) + c`), eliminating all coordinate bounds checks.
   - Encodes every cuboid state as a 12-bit integer `state = (orient << 10) | idx` in `0..3071` and performs branchless orientation transitions via 12-entry lookup tables (`next_orient`, `next_delta`, `second_off`).
