Require Import Arith.
Require Export Preloaded.

Lemma add_0_r_local : forall n : nat, n + 0 = n.
Proof.
  induction n as [| n IHn]; simpl.
  - reflexivity.
  - f_equal. exact IHn.
Qed.

Lemma add_succ_r_local : forall n m : nat, n + S m = S (n + m).
Proof.
  induction n as [| n IHn]; intros m; simpl.
  - reflexivity.
  - f_equal. apply IHn.
Qed.

Lemma add_comm_local : forall n m : nat, n + m = m + n.
Proof.
  induction n as [| n IHn]; intros m; simpl.
  - symmetry. apply add_0_r_local.
  - rewrite IHn. symmetry. apply add_succ_r_local.
Qed.

Lemma fib_aux_spec : forall n k : nat,
  fib_aux (fib k) (fib (S k)) n = fib (n + k).
Proof.
  induction n as [| n IHn]; intros k.
  - reflexivity.
  - change (fib_aux (fib k) (fib (S k)) (S n))
      with (fib_aux (fib (S k)) (fib k + fib (S k)) n).
    rewrite (add_comm_local (fib k) (fib (S k))).
    change (fib (S k) + fib k) with (fib (S (S k))).
    rewrite (IHn (S k)).
    rewrite add_succ_r_local.
    reflexivity.
Qed.

Theorem fib_eq : forall (n : nat), fib2 n = fib n.
Proof.
  intros n.
  change (fib2 n) with (fib_aux (fib 0) (fib 1) n).
  rewrite (fib_aux_spec n 0).
  rewrite add_0_r_local.
  reflexivity.
Qed.

Definition fibEq := fib_eq.
Definition fib_correct := fib_eq.
Definition fib2_eq := fib_eq.
