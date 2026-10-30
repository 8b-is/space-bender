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
