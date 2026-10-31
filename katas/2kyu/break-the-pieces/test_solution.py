#!/usr/bin/env python3
"""Verification runner for Break the pieces (2 kyu, C++20 + x86-64 NASM + AArch64 ASM, 527fde8d24b9309d9b000c4e)."""

import os
import subprocess
import tempfile

if __name__ == "__main__":
    here = os.path.dirname(os.path.abspath(__file__))
    with tempfile.TemporaryDirectory() as tmp:
        # 1. Verify x86-64 NASM assembly syntax & machine-code generation
        x86_obj = os.path.join(tmp, "solution_x86_64.o")
        subprocess.run(
            ["nasm", "-f", "elf64", "-w+error", os.path.join(here, "solution.asm"), "-o", x86_obj],
            cwd=here,
            check=True,
        )

        # 2. Compile & execute C++20 + native AArch64 assembly on Apple Silicon
        bin_path = os.path.join(tmp, "test_solution")
        subprocess.run(
            [
                "clang++",
                "-std=c++20",
                "-O2",
                os.path.join(here, "test_solution.cpp"),
                os.path.join(here, "solution_arm64.s"),
                "-o",
                bin_path,
            ],
            cwd=here,
            check=True,
        )
        res = subprocess.run([bin_path], cwd=here, check=True, capture_output=True, text=True)
        print(res.stdout.strip())
