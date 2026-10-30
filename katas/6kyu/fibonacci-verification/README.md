# Program Verification #2: Fibonacci numbers (Coq)

**Kyu:** 6 · **Source:** [Codewars](https://www.codewars.com/kata/5c8b3e55b9d1190016bd3cca) · **ID:** `5c8b3e55b9d1190016bd3cca`
(Coq / Idris / Agda / Lean, by `monadius`)

Given the naive exponential Fibonacci definition `fib` and the linear tail-recursive accumulator `fib2`:

```coq
Fixpoint fib (n : nat) : nat :=
  match n with
  | 0 => 0
  | 1 => 1
  | S (S n as n') => fib n' + fib n
  end.

Fixpoint fib_aux (a b n : nat) : nat :=
  match n with
  | 0 => a
  | S n => fib_aux b (a + b) n
  end.

Definition fib2 (n : nat) : nat := fib_aux 0 1 n.
```

Prove that `forall (n : nat), fib2 n = fib n` (`Closed under the global context`).

## Solution

Direct induction on `n` in `fib_aux 0 1 n = fib n` gets stuck because the accumulator pair `(0, 1)` shifts to `(1, 1)`, `(1, 2)`, `(2, 3)`, ..., `(fib k, fib (S k))` on every step.

Instead of introducing multiplication (`a * fib n + b * fib (S n)`), we generalize the starting index `k` of the adjacent Fibonacci pair `(fib k, fib (S k))`:

```coq
Lemma fib_aux_spec : forall n k : nat,
  fib_aux (fib k) (fib (S k)) n = fib (n + k).
```

1. **Base case (`n = 0`)**:
   `fib_aux (fib k) (fib (S k)) 0` reduces definitionally to `fib k`, and `fib (0 + k)` reduces definitionally to `fib k` (`reflexivity`).
2. **Inductive step (`n = S n'`)**:
   - `fib_aux (fib k) (fib (S k)) (S n')` unfolds to `fib_aux (fib (S k)) (fib k + fib (S k)) n'`.
   - Commuting `fib k + fib (S k)` to `fib (S k) + fib k` produces `fib (S (S k))` by definition of `fib`.
   - Applying the induction hypothesis `IHn (S k)` gives `fib (n' + S k)`, which rewrites via `add_succ_r` (`n' + S k = S (n' + k)`) to `fib (S n' + k)`.
3. **Instantiating `k = 0`**:
   Since `fib 0 = 0` and `fib 1 = 1`, `fib2 n` is definitionally `fib_aux (fib 0) (fib 1) n = fib (n + 0) = fib n`.

## Files

- `solution.v` — Coq proof of `fib_aux_spec` and `fib_eq` (`Closed under the global context`)
- `test_solution.v` — Codewars `Print Assumptions` harness
- `test_solution.py` — `coqc` compiler harness + constructive invariant verifier
- `bluesky-receipt.json` — live 4-post ELI5 educational Bluesky thread receipt ([root post on `@0xp3t3rl.bsky.social`](https://bsky.app/profile/0xp3t3rl.bsky.social/post/3mz3dycuzze2a))
