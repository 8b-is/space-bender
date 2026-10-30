# Game of Life in Reverse (1 kyu · Factor)

- **Codewars Kata**: [Game of Life in Reverse](https://www.codewars.com/kata/5ea6a8502186ab001427809e) (`5ea6a8502186ab001427809e`)
- **Language**: Factor (`0.102`)
- **Entrypoint**: `find-predecessor ( goal -- pred )` in vocabulary `reverse-life`

## Key Ideas

1. **Order-Independent Interval Feasibility (`cell-valid?`)**:
   Each cell $q$ in the $(m+2) \times (n+2)$ grid tracks its placed live-neighbor count $c_q$, remaining unplaced neighbors $r_q$, and state $s_q$ (initialized to $t_q = \text{target}[q]$ while unplaced). At every step, $q$ remains feasible iff:
   - $t_q = 1$: $(c_q \le 3) \land (c_q + r_q + s_q \ge 3)$
   - $t_q = 0$: $(c_q + s_q < 3) \lor (c_q + r_q > 3)$
2. **Sliding-Window Frontier Memoization (`frontier-key`)**:
   In raster order, only the $W + 1$ cells $q \in [\text{idx} - W - 1, \text{idx} - 1]$ interact with undecided cells $\ge \text{idx}$. Packing $(\min(c_q, 4), s_q)$ into 4 bits per frontier cell produces a single fixnum key cached in `dead` (`HS{ }`), turning exponential backtracking into bounded profile DP and rejecting Garden of Eden patterns in milliseconds.
3. **Aspect & Density Normalization**:
   Transposes the grid when $n > m$ so the frontier width $W = \min(m, n) + 2$ is minimized, and flips vertically when live cells are heavier in the bottom half so constraints are encountered immediately.
