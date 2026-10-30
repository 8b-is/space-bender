# ASCII Games: Dance Dance Evolution I (2 kyu — Rust)

- **Codewars Kata**: [ASCII Games: Dance Dance Evolution I](https://www.codewars.com/kata/58f58dc3663082a4ba000033/rust)
- **ID**: `58f58dc3663082a4ba000033`
- **Language**: Rust

## Overview

Given a rectangular maze of directional arrows (`←↖↑↗→↘↓↙`) and a starting tile `S`, find the longest simple cycle starting and ending at `S` such that every move direction $d$ is within $90^\circ$ ($\le 2$ steps on the 8-point compass) of both the arrow on the current tile and the arrow on the destination tile.

## Algorithm

1. **Directed Graph Compilation (`u64` Bitmasks)**:
   - Precomputes valid transitions $u \xrightarrow{d} v$ where both `tile[u]` and `tile[v]` are within $90^\circ$ of $d$ (or `'S'`), storing outgoing adjacency lists `adj[u]` alongside 64-bit masks `out_mask[u]` and `in_mask[v]`.
2. **Bidirectional Bitmask Reachability Pruning**:
   - At each DFS state `(u, visited)`, computes backward reachability `can_reach_s` from `S` through unvisited arrow nodes using `trailing_zeros()` bit-scans, and then forward reachability `reachable` from `u` restricted to `can_reach_s`.
   - Any neighbor not in `reachable` is dead-end pruned in $O(1)$, and `cur.len() + reachable.count_ones() + 1 <= best.len()` provides a tight upper-bound cutoff.
