#!/usr/bin/env python3
"""Verification runner for Beeramid (5 kyu, SWI-Prolog, 51e04f6b544cf3f6550000c1)."""

import os
import shutil
import subprocess

if __name__ == "__main__":
    here = os.path.dirname(os.path.abspath(__file__))
    swipl = shutil.which("swipl") or "/opt/homebrew/bin/swipl"
    res = subprocess.run(
        [swipl, "-q", "-g", "run_tests", "-t", "halt", os.path.join(here, "test.pl")],
        cwd=here,
        check=True,
        capture_output=True,
        text=True,
    )
    out = (res.stdout + "\n" + res.stderr).strip()
    if out:
        print(out)
    print("ALL PROLOG BEERAMID SUITES PASSED!")
