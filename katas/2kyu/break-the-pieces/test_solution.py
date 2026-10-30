#!/usr/bin/env python3
"""Verification runner for Break the pieces (2 kyu, C++, 527fde8d24b9309d9b000c4e)."""

import os
import subprocess
import tempfile

if __name__ == "__main__":
    here = os.path.dirname(os.path.abspath(__file__))
    with tempfile.TemporaryDirectory() as tmp:
        bin_path = os.path.join(tmp, "test_solution")
        subprocess.run(
            ["clang++", "-std=c++20", "-O2", os.path.join(here, "test_solution.cpp"), "-o", bin_path],
            cwd=here,
            check=True,
        )
        res = subprocess.run([bin_path], cwd=here, check=True, capture_output=True, text=True)
        print(res.stdout.strip())
