# A+A=B+B so A=B? Prove it! (Coq)

**Kyu:** 6 · **Source:** [Codewars](https://www.codewars.com/kata/5c8531a820089d04385a7faa) · **ID:** `5c8531a820089d04385a7faa`
(Coq / Idris / Agda, by `ice1000`)

Prove in Coq (`Require Import Arith.`) with zero axioms (`Closed under the global context`):

```coq
Theorem invert : forall a b : nat, a + a = b + b -> a = b.
```

## Solution

By structural induction on `a : nat` with `b : nat` generalized (`induction a as [| a IHa]; intros [| b] H; simpl in H`):

1. **Base cases (`(0, 0)`, `(0, S b)`, `(S a, 0)`)**:
   - `(0, 0)` holds immediately by `reflexivity`.
   - `(0, S b)` and `(S a, 0)` have hypotheses `0 = S (b + S b)` and `S (a + S a) = 0`, which are impossible by constructor disjointness (`discriminate H`).
2. **Inductive step (`a = S a'`, `b = S b'`)**:
   - Simplifying `S a' + S a' = S b' + S b'` on the left-recursive `+` argument yields `S (a' + S a') = S (b' + S b')`.
   - Rewriting both sides with `add_succ_r : forall n m, n + S m = S (n + m)` turns `H` into `S (S (a' + a')) = S (S (b' + b'))`.
   - `inversion H as [H1]` (constructor injectivity of `S` twice) extracts `H1 : a' + a' = b' + b'`.
   - Applying `f_equal` and the inductive hypothesis `IHa` on `H1` yields `S a' = S b'`.

```coq
Require Import Arith.

Lemma add_succ_r : forall n m : nat, n + S m = S (n + m).
Proof.
  induction n as [| n IHn]; intros m; simpl.
  - reflexivity.
  - f_equal. apply IHn.
Qed.

Theorem invert : forall a b : nat, a + a = b + b -> a = b.
Proof.
  induction a as [| a IHa]; intros [| b] H; simpl in H.
  - reflexivity.
  - discriminate H.
  - discriminate H.
  - rewrite add_succ_r in H.
    rewrite add_succ_r in H.
    inversion H as [H1].
    f_equal.
    apply IHa.
    exact H1.
Qed.
```

## Files

- `solution.v` — Coq proof of `invert` (`Closed under the global context`)
- `test_solution.v` — Codewars `invert_test` + `Print Assumptions invert_test` harness
- `test_solution.py` — `coqc` compiler harness + constructive Peano proof term verifier
- `bluesky-receipt.json` — live 4-post ELI5 educational Bluesky thread receipt ([root post on `@0xp3t3rl.bsky.social`](https://bsky.app/profile/0xp3t3rl.bsky.social/post/3mz3dqrzcqy2r))
