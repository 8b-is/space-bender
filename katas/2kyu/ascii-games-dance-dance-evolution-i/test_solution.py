#!/usr/bin/env python3
"""Verification runner for ASCII Games: Dance Dance Evolution I (2 kyu, Rust + x86-64 NASM + AArch64 ASM, 58f58dc3663082a4ba000033)."""

import os
import subprocess
import tempfile

if __name__ == "__main__":
    here = os.path.dirname(os.path.abspath(__file__))
    with tempfile.TemporaryDirectory() as tmp:
        x86_obj = os.path.join(tmp, "solution_x86_64.o")
        subprocess.run(
            ["nasm", "-f", "elf64", "-w+error", os.path.join(here, "solution.asm"), "-o", x86_obj],
            cwd=here,
            check=True,
        )

    res = subprocess.run(
        ["cargo", "test", "--release", "--", "--nocapture"],
        cwd=here,
        check=True,
        capture_output=True,
        text=True,
    )
    print(res.stdout.strip())
