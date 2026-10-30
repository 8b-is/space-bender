#!/usr/bin/env python3
"""Verification runner for ASCII Games: Dance Dance Evolution I (2 kyu, Rust, 58f58dc3663082a4ba000033)."""

import os
import subprocess

if __name__ == "__main__":
    here = os.path.dirname(os.path.abspath(__file__))
    res = subprocess.run(
        ["cargo", "test", "--release", "--", "--nocapture"],
        cwd=here,
        check=True,
        capture_output=True,
        text=True,
    )
    print(res.stdout.strip())
