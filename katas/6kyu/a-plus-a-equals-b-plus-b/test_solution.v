Require Import Arith.
Require Solution.

Theorem invert_test : forall a b : nat, Init.Nat.add a a = Init.Nat.add b b -> a = b.
Proof.
  exact Solution.invert.
Qed.
Print Assumptions invert_test.
