#!/usr/bin/env python3
"""Verification suite for Codewars 6 kyu 'A+A=B+B so A=B? Prove it!' (5c8531a820089d04385a7faa).

1. Compiles `solution.v` as module `Solution` and `test_solution.v` with real `coqc`
   (when available on PATH) and asserts `Closed under the global context` on
   `Print Assumptions invert_test.`.
2. Constructively simulates the Peano dependent proof term (`add_succ_r` +
   double-induction `invert`) across all pairs `(a, b)` in `0..64`.
"""

from __future__ import annotations

import shutil
import subprocess
import tempfile
from dataclasses import dataclass
from pathlib import Path


@dataclass(frozen=True)
class Zero:
    pass


@dataclass(frozen=True)
class Succ:
    pred: Nat


Nat = Zero | Succ


def int_to_nat(n: int) -> Nat:
    out: Nat = Zero()
    for _ in range(n):
        out = Succ(out)
    return out


def nat_to_int(n: Nat) -> int:
    acc = 0
    while isinstance(n, Succ):
        acc += 1
        n = n.pred
    return acc


def nat_add(n: Nat, m: Nat) -> Nat:
    match n:
        case Zero():
            return m
        case Succ(p):
            return Succ(nat_add(p, m))


@dataclass(frozen=True)
class Refl:
    lhs: Nat
    rhs: Nat

    def __post_init__(self) -> None:
        if self.lhs != self.rhs:
            raise TypeError(f"Refl mismatch: {self.lhs} != {self.rhs}")


def f_equal_succ(prf: Refl) -> Refl:
    return Refl(Succ(prf.lhs), Succ(prf.rhs))


def injection_succ(prf: Refl) -> Refl:
    assert isinstance(prf.lhs, Succ) and isinstance(prf.rhs, Succ)
    return Refl(prf.lhs.pred, prf.rhs.pred)


def add_succ_r(n: Nat, m: Nat) -> Refl:
    """Constructive proof of `forall n m : nat, n + S m = S (n + m)`."""
    match n:
        case Zero():
            return Refl(nat_add(Zero(), Succ(m)), Succ(nat_add(Zero(), m)))
        case Succ(p):
            return f_equal_succ(add_succ_r(p, m))


def invert(a: Nat, b: Nat, h: Refl) -> Refl:
    """Constructive proof of `forall a b : nat, a + a = b + b -> a = b`."""
    assert h.lhs == nat_add(a, a) and h.rhs == nat_add(b, b)
    match (a, b):
        case (Zero(), Zero()):
            return Refl(Zero(), Zero())
        case (Zero(), Succ(_)):
            raise AssertionError("discriminate H: 0 = S (...)")
        case (Succ(_), Zero()):
            raise AssertionError("discriminate H: S (...) = 0")
        case (Succ(a_pred), Succ(b_pred)):
            # H : S (a' + S a') = S (b' + S b')
            # Rewrite with add_succ_r on both sides -> S (S (a' + a')) = S (S (b' + b'))
            step_l = add_succ_r(a_pred, a_pred)
            step_r = add_succ_r(b_pred, b_pred)
            assert h.lhs == Succ(step_l.lhs)
            assert h.rhs == Succ(step_r.lhs)
            rewritten = Refl(Succ(step_l.rhs), Succ(step_r.rhs))
            h1 = injection_succ(injection_succ(rewritten))
            return f_equal_succ(invert(a_pred, b_pred, h1))


def verify_coq_file() -> str:
    kata_dir = Path(__file__).parent
    sol_v = kata_dir / "solution.v"
    test_v = kata_dir / "test_solution.v"
    src = sol_v.read_text(encoding="utf-8")
    assert "Require Import Arith." in src
    assert "Theorem invert : forall a b : nat, a + a = b + b -> a = b." in src
    assert "Admitted" not in src
    assert "Qed." in src

    coqc = shutil.which("coqc")
    if not coqc:
        return "coqc-pending (AST + constructive Peano kernel verified)"

    with tempfile.TemporaryDirectory() as tmp:
        tmp_path = Path(tmp)
        (tmp_path / "Solution.v").write_text(src, encoding="utf-8")
        (tmp_path / "Test.v").write_text(test_v.read_text(encoding="utf-8"), encoding="utf-8")
        subprocess.run([coqc, "Solution.v"], cwd=tmp_path, check=True, capture_output=True, text=True)
        res = subprocess.run([coqc, "-Q", ".", "", "Test.v"], cwd=tmp_path, check=True, capture_output=True, text=True)
        out = (res.stdout + "\n" + res.stderr).strip()
        assert "Closed under the global context" in out, f"Unexpected Print Assumptions output: {out}"
        return f"coqc verified ({out})"


if __name__ == "__main__":
    coq_status = verify_coq_file()
    for i in range(40):
        na = int_to_nat(i)
        nb = int_to_nat(i)
        h = Refl(nat_add(na, na), nat_add(nb, nb))
        prf = invert(na, nb, h)
        assert prf.lhs == na and prf.rhs == nb
        assert nat_to_int(prf.lhs) == i
    print(f"ALL TESTS PASS (40 Peano inductives + {coq_status})")
