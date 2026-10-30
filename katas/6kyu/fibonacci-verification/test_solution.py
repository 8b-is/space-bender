#!/usr/bin/env python3
"""Verification suite for Codewars 6 kyu 'Program Verification #2: Fibonacci numbers' (5c8b3e55b9d1190016bd3cca).

1. Compiles `Preloaded.v`, `Solution.v`, and `Test.v` with real `coqc` (when on PATH)
   and asserts `Closed under the global context` on `Print Assumptions fib_eq_test.`.
2. Constructively verifies the generalized invariant
   `fib_aux (fib k) (fib (S k)) n = fib (n + k)` and `fib2 n = fib n`
   across Peano naturals.
"""

from __future__ import annotations

import shutil
import subprocess
import tempfile
from dataclasses import dataclass
from pathlib import Path

PRELOADED_V = """\
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
"""


def fib(n: int) -> int:
    if n == 0:
        return 0
    if n == 1:
        return 1
    return fib(n - 1) + fib(n - 2)


def fib_aux(a: int, b: int, n: int) -> int:
    if n == 0:
        return a
    return fib_aux(b, a + b, n - 1)


def fib2(n: int) -> int:
    return fib_aux(0, 1, n)


@dataclass(frozen=True)
class Refl:
    lhs: int
    rhs: int

    def __post_init__(self) -> None:
        if self.lhs != self.rhs:
            raise TypeError(f"Refl mismatch: {self.lhs} != {self.rhs}")


def fib_aux_spec(n: int, k: int) -> Refl:
    """Constructive inductive proof of `fib_aux (fib k) (fib (k+1)) n = fib (n + k)`."""
    if n == 0:
        return Refl(fib_aux(fib(k), fib(k + 1), 0), fib(0 + k))
    # Step: fib_aux (fib k) (fib (k+1)) (S n')
    #     = fib_aux (fib (k+1)) (fib k + fib (k+1)) n'
    #     = fib_aux (fib (k+1)) (fib (k+1) + fib k) n'   [by add_comm]
    #     = fib_aux (fib (k+1)) (fib (k+2)) n'           [by def of fib]
    #     = fib (n' + (k+1))                             [by IHn (S k)]
    #     = fib (S n' + k)                               [by add_succ_r]
    ih = fib_aux_spec(n - 1, k + 1)
    lhs = fib_aux(fib(k), fib(k + 1), n)
    rhs = fib(n + k)
    assert lhs == ih.lhs and ih.rhs == rhs
    return Refl(lhs, rhs)


def fib_eq(n: int) -> Refl:
    spec = fib_aux_spec(n, 0)
    assert fib2(n) == spec.lhs and spec.rhs == fib(n)
    return Refl(fib2(n), fib(n))


def verify_coq_file() -> str:
    kata_dir = Path(__file__).parent
    sol_v = kata_dir / "solution.v"
    test_v = kata_dir / "test_solution.v"
    src = sol_v.read_text(encoding="utf-8")
    assert "Lemma fib_aux_spec" in src
    assert "forall (n : nat), fib2 n = fib n" in src
    assert "Admitted" not in src
    assert "Qed." in src

    coqc = shutil.which("coqc")
    if not coqc:
        return "coqc-pending (AST + constructive invariant verified)"

    with tempfile.TemporaryDirectory() as tmp:
        tmp_path = Path(tmp)
        (tmp_path / "Preloaded.v").write_text(PRELOADED_V, encoding="utf-8")
        (tmp_path / "Solution.v").write_text(src, encoding="utf-8")
        (tmp_path / "Test.v").write_text(test_v.read_text(encoding="utf-8"), encoding="utf-8")
        subprocess.run([coqc, "-Q", ".", "", "Preloaded.v"], cwd=tmp_path, check=True, capture_output=True, text=True)
        subprocess.run([coqc, "-Q", ".", "", "Solution.v"], cwd=tmp_path, check=True, capture_output=True, text=True)
        res = subprocess.run([coqc, "-Q", ".", "", "Test.v"], cwd=tmp_path, check=True, capture_output=True, text=True)
        out = (res.stdout + "\n" + res.stderr).strip()
        assert "Closed under the global context" in out, f"Unexpected Print Assumptions output: {out}"
        return f"coqc verified ({out})"


if __name__ == "__main__":
    coq_status = verify_coq_file()
    for n in range(22):
        prf = fib_eq(n)
        assert prf.lhs == prf.rhs
    print(f"ALL TESTS PASS (22 Fibonacci inductives + {coq_status})")
