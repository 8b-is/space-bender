Require Import Arith.
Require Preloaded.
Require Solution.

Theorem fib_eq_test : forall (n : nat), Preloaded.fib2 n = Preloaded.fib n.
Proof.
  exact Solution.fib_eq.
Qed.
Print Assumptions fib_eq_test.
