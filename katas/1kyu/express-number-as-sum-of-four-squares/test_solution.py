#!/usr/bin/env python3
"""Verification runner for Express number as sum of four squares (1 kyu, Rust, 63022799acfb8d00285b4ea0)."""

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
