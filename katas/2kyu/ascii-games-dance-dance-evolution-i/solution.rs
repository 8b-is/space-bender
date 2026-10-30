//! Codewars 2 kyu — ASCII Games: Dance Dance Evolution I
//! ID: 58f58dc3663082a4ba000033
//!
//! Finds the longest simple cycle starting and ending at `S` on an arrow grid
//! where every step direction `d` is within 90° of both the current tile's arrow
//! and the destination tile's arrow.

const ARROWS: [char; 8] = ['←', '↖', '↑', '↗', '→', '↘', '↓', '↙'];
const DR: [isize; 8] = [0, -1, -1, -1, 0, 1, 1, 1];
const DC: [isize; 8] = [-1, -1, 0, 1, 1, 1, 0, -1];

#[inline]
fn arrow_idx(ch: char) -> Option<u8> {
    match ch {
        '←' => Some(0),
        '↖' => Some(1),
        '↑' => Some(2),
        '↗' => Some(3),
        '→' => Some(4),
        '↘' => Some(5),
        '↓' => Some(6),
        '↙' => Some(7),
        'S' => Some(8),
        _ => None,
    }
}

#[inline]
fn is_compatible(tile_dir: u8, move_dir: u8) -> bool {
    if tile_dir >= 8 {
        return true;
    }
    let diff = tile_dir.abs_diff(move_dir);
    diff <= 2 || diff >= 6
}

pub fn dance(map: &str) -> String {
    let grid: Vec<Vec<u8>> = map
        .lines()
        .filter(|l| !l.is_empty())
        .map(|l| l.chars().filter_map(arrow_idx).collect())
        .collect();

    let rows = grid.len();
    if rows == 0 {
        return String::new();
    }
    let cols = grid[0].len();
    let n = rows * cols;
    if cols == 0 || n > 64 {
        return String::new();
    }

    let mut start = None;
    let mut tiles = vec![0u8; n];
    for r in 0..rows {
        for c in 0..cols {
            let idx = r * cols + c;
            tiles[idx] = grid[r][c];
            if grid[r][c] == 8 {
                start = Some(idx);
            }
        }
    }
    let start = match start {
        Some(s) => s,
        None => return String::new(),
    };

    let mut adj = vec![Vec::<(usize, u8)>::with_capacity(8); n];
    let mut out_mask = vec![0u64; n];
    let mut in_mask = vec![0u64; n];

    for r in 0..rows {
        for c in 0..cols {
            let u = r * cols + c;
            let tu = tiles[u];
            for d in 0..8u8 {
                let nr = r as isize + DR[d as usize];
                let nc = c as isize + DC[d as usize];
                if nr < 0 || nr >= rows as isize || nc < 0 || nc >= cols as isize {
                    continue;
                }
                let v = (nr as usize) * cols + (nc as usize);
                let tv = tiles[v];
                if is_compatible(tu, d) && is_compatible(tv, d) {
                    adj[u].push((v, d));
                    out_mask[u] |= 1u64 << v;
                    in_mask[v] |= 1u64 << u;
                }
            }
        }
    }

    let all_arrows_mask: u64 = if n == 64 {
        !0u64 ^ (1u64 << start)
    } else {
        ((1u64 << n) - 1) ^ (1u64 << start)
    };

    struct Solver<'a> {
        start: usize,
        adj: &'a [Vec<(usize, u8)>],
        out_mask: &'a [u64],
        in_mask: &'a [u64],
        all_arrows_mask: u64,
        cur: Vec<u8>,
        best: Vec<u8>,
    }

    impl<'a> Solver<'a> {
        fn dfs(&mut self, u: usize, visited: u64) {
            let avail = (!visited) & self.all_arrows_mask;

            // 1. Backward reachability from `start` through unvisited arrow tiles
            let mut can_reach_s = self.in_mask[self.start] & avail;
            loop {
                let mut next = can_reach_s;
                let mut m = can_reach_s;
                while m != 0 {
                    let v = m.trailing_zeros() as usize;
                    m &= m - 1;
                    next |= self.in_mask[v] & avail;
                }
                if next == can_reach_s {
                    break;
                }
                can_reach_s = next;
            }

            // 2. Forward reachability from `u` restricted to `can_reach_s`
            let mut reachable = self.out_mask[u] & can_reach_s;
            loop {
                let mut next = reachable;
                let mut m = reachable;
                while m != 0 {
                    let v = m.trailing_zeros() as usize;
                    m &= m - 1;
                    next |= self.out_mask[v] & can_reach_s;
                }
                if next == reachable {
                    break;
                }
                reachable = next;
            }

            // Check direct step back to `start` if we have at least 1 step
            if !self.cur.is_empty() && ((self.out_mask[u] >> self.start) & 1) != 0 {
                if self.cur.len() + 1 > self.best.len() {
                    for &(v, d) in &self.adj[u] {
                        if v == self.start {
                            self.best.clear();
                            self.best.extend_from_slice(&self.cur);
                            self.best.push(d);
                            break;
                        }
                    }
                }
            }

            // Upper-bound prune: cur.len() + reachable arrows + 1 final step to start
            let max_possible = self.cur.len() + (reachable.count_ones() as usize) + 1;
            if max_possible <= self.best.len() {
                return;
            }

            for &(v, d) in &self.adj[u] {
                if ((reachable >> v) & 1) != 0 {
                    self.cur.push(d);
                    self.dfs(v, visited | (1u64 << v));
                    self.cur.pop();
                    if self.cur.len() + (reachable.count_ones() as usize) + 1 <= self.best.len() {
                        break;
                    }
                }
            }
        }
    }

    let mut solver = Solver {
        start,
        adj: &adj,
        out_mask: &out_mask,
        in_mask: &in_mask,
        all_arrows_mask,
        cur: Vec::with_capacity(n),
        best: Vec::with_capacity(n),
    };

    solver.dfs(start, 0);

    solver.best.into_iter().map(|d| ARROWS[d as usize]).collect()
}
