use ascii_games_dance_dance_evolution_i::dance;
use std::collections::HashSet;
use std::time::Instant;

const ARROWS: [char; 8] = ['←', '↖', '↑', '↗', '→', '↘', '↓', '↙'];
const DR: [isize; 8] = [0, -1, -1, -1, 0, 1, 1, 1];
const DC: [isize; 8] = [-1, -1, 0, 1, 1, 1, 0, -1];

fn dir_of(ch: char) -> Option<usize> {
    ARROWS.iter().position(|&c| c == ch)
}

fn within_90(a: usize, b: usize) -> bool {
    let diff = a.abs_diff(b);
    diff <= 2 || diff >= 6
}

fn verify_cycle(map: &str, moves: &str) -> Result<usize, String> {
    if moves.is_empty() {
        return Ok(0);
    }
    let grid: Vec<Vec<char>> = map
        .lines()
        .filter(|l| !l.is_empty())
        .map(|l| l.chars().collect())
        .collect();
    let rows = grid.len() as isize;
    let cols = grid[0].len() as isize;

    let mut sr = -1;
    let mut sc = -1;
    for r in 0..rows {
        for c in 0..cols {
            if grid[r as usize][c as usize] == 'S' {
                sr = r;
                sc = c;
            }
        }
    }

    let mut r = sr;
    let mut c = sc;
    let mut visited = HashSet::new();
    let move_chars: Vec<char> = moves.chars().collect();

    for (step_idx, &mv) in move_chars.iter().enumerate() {
        let d = dir_of(mv).ok_or_else(|| format!("Invalid move char: {}", mv))?;
        let cur_tile = grid[r as usize][c as usize];
        if cur_tile != 'S' {
            let td = dir_of(cur_tile).unwrap();
            if !within_90(td, d) {
                return Err(format!(
                    "Step {} from ({},{}) tile {} in dir {} violates 90° rule",
                    step_idx, r, c, cur_tile, mv
                ));
            }
        }
        let nr = r + DR[d];
        let nc = c + DC[d];
        if nr < 0 || nr >= rows || nc < 0 || nc >= cols {
            return Err(format!("Step {} went out of bounds to ({},{})", step_idx, nr, nc));
        }
        let next_tile = grid[nr as usize][nc as usize];
        if next_tile == 'S' {
            if step_idx + 1 != move_chars.len() {
                return Err(format!("Returned to S early at step {}", step_idx));
            }
        } else {
            let nd = dir_of(next_tile).unwrap();
            if !within_90(nd, d) {
                return Err(format!(
                    "Step {} onto ({},{}) tile {} in dir {} violates 90° rule",
                    step_idx, nr, nc, next_tile, mv
                ));
            }
            if !visited.insert((nr, nc)) {
                return Err(format!("Stepped on ({},{}) twice at step {}", nr, nc, step_idx));
            }
        }
        r = nr;
        c = nc;
    }

    if (r, c) != (sr, sc) {
        return Err(format!("Ended at ({},{}) instead of S ({},{})", r, c, sr, sc));
    }
    Ok(move_chars.len())
}

fn reference_longest_len(map: &str) -> usize {
    let grid: Vec<Vec<char>> = map
        .lines()
        .filter(|l| !l.is_empty())
        .map(|l| l.chars().collect())
        .collect();
    let rows = grid.len() as isize;
    let cols = grid[0].len() as isize;
    let mut sr = 0isize;
    let mut sc = 0isize;
    for r in 0..rows {
        for c in 0..cols {
            if grid[r as usize][c as usize] == 'S' {
                sr = r;
                sc = c;
            }
        }
    }

    fn dfs_ref(
        grid: &[Vec<char>],
        rows: isize,
        cols: isize,
        sr: isize,
        sc: isize,
        r: isize,
        c: isize,
        len: usize,
        vis: &mut Vec<Vec<bool>>,
        best: &mut usize,
    ) {
        let cur_tile = grid[r as usize][c as usize];
        for d in 0..8 {
            if cur_tile != 'S' && !within_90(dir_of(cur_tile).unwrap(), d) {
                continue;
            }
            let nr = r + DR[d];
            let nc = c + DC[d];
            if nr < 0 || nr >= rows || nc < 0 || nc >= cols {
                continue;
            }
            let next_tile = grid[nr as usize][nc as usize];
            if next_tile == 'S' {
                if len > 0 && len + 1 > *best {
                    *best = len + 1;
                }
                continue;
            }
            if vis[nr as usize][nc as usize] {
                continue;
            }
            if !within_90(dir_of(next_tile).unwrap(), d) {
                continue;
            }
            vis[nr as usize][nc as usize] = true;
            dfs_ref(grid, rows, cols, sr, sc, nr, nc, len + 1, vis, best);
            vis[nr as usize][nc as usize] = false;
        }
    }

    let mut vis = vec![vec![false; cols as usize]; rows as usize];
    let mut best = 0;
    dfs_ref(&grid, rows, cols, sr, sc, sr, sc, 0, &mut vis, &mut best);
    best
}

#[test]
fn test_example_mazes() {
    let example = "↖→↓←↗\n↑←↓→↓\n↑→S←↓\n↑←↓→↓\n↙→↑←↘";
    let res = dance(example);
    let len = verify_cycle(example, &res).expect("Valid cycle required");
    assert_eq!(len, 19);

    let example_alt = "↘→↓←↙\n↑←↓→↓\n↑→S←↓\n↑←↓→↓\n↗→↑←↖";
    let res_alt = dance(example_alt);
    let len_alt = verify_cycle(example_alt, &res_alt).expect("Valid cycle required");
    assert_eq!(len_alt, reference_longest_len(example_alt));
}

#[test]
fn test_no_cycle() {
    // All arrows point outward from S so returning to S is impossible (180° opposite)
    let trap = "↖↑↗\n←S→\n↙↓↘";
    let res = dance(trap);
    assert_eq!(res, "");
}

#[test]
fn test_100_random_5x5_mazes() {
    let mut seed: u64 = 0xDEAD_BEEF_CAFE_BABEu64;
    let mut next_u64 = || -> u64 {
        seed ^= seed << 13;
        seed ^= seed >> 7;
        seed ^= seed << 17;
        seed
    };

    let t0 = Instant::now();
    for _ in 0..100 {
        let sr = (next_u64() % 5) as usize;
        let sc = (next_u64() % 5) as usize;
        let mut lines = Vec::with_capacity(5);
        for r in 0..5 {
            let mut row = String::new();
            for c in 0..5 {
                if r == sr && c == sc {
                    row.push('S');
                } else {
                    row.push(ARROWS[(next_u64() % 8) as usize]);
                }
            }
            lines.push(row);
        }
        let map = lines.join("\n");
        let ans = dance(&map);
        let len = verify_cycle(&map, &ans).expect("Returned invalid cycle");
        let expected = reference_longest_len(&map);
        assert_eq!(len, expected, "Suboptimal cycle on map:\n{}", map);
    }
    let elapsed = t0.elapsed();
    println!("Verified 100 random 5x5 mazes in {:?}", elapsed);
}
