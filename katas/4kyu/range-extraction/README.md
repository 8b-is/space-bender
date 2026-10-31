# Range Extraction (4 kyu — Haskell + Julia + x86-64 NASM + AArch64 Assembly)

- **Codewars Kata**: [Range Extraction](https://www.codewars.com/kata/51ba717bb08c1cd60f00002f)
- **ID**: `51ba717bb08c1cd60f00002f`
- **Languages**: Haskell (`solution.hs`), Julia (`solution.jl`), x86-64 NASM (`solution.asm`), Apple Silicon AArch64 (`solution_arm64.s`)

## Overview

Compresses a strictly increasing sequence of integers into comma-separated entries where maximal contiguous runs $[a..b]$ of length $\ge 3$ ($b - a \ge 2$) are formatted as `"a-b"`, while runs of length $1$ or $2$ are emitted individually (`"a"` or `"a,b"`).
