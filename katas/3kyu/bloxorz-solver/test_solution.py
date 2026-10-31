#!/usr/bin/env python3
"""Verification runner for Bloxorz Solver (3 kyu, Haskell + x86-64 NASM + AArch64 ASM, 5a2a597a8882f392020005e5)."""

import os
import subprocess
import tempfile

if __name__ == "__main__":
    here = os.path.dirname(os.path.abspath(__file__))
    with tempfile.TemporaryDirectory() as tmp:
        # 1. Verify x86-64 NASM assembly syntax & ELF64 object generation
        x86_obj = os.path.join(tmp, "solution_x86_64.o")
        subprocess.run(
            ["nasm", "-f", "elf64", "-w+error", os.path.join(here, "solution.asm"), "-o", x86_obj],
            cwd=here,
            check=True,
        )

        # 2. Verify native AArch64 assembly solver on Apple Silicon
        asm_bin = os.path.join(tmp, "test_asm")
        subprocess.run(
            [
                "clang++",
                "-std=c++20",
                "-O2",
                os.path.join(here, "test_asm.cpp"),
                os.path.join(here, "solution_arm64.s"),
                "-o",
                asm_bin,
            ],
            cwd=here,
            check=True,
        )
        res_asm = subprocess.run([asm_bin], cwd=here, check=True, capture_output=True, text=True)
        print(res_asm.stdout.strip())

        # 3. Verify Haskell solution (`solution.hs`) via GHC
        hs_bin = os.path.join(tmp, "test_hs")
        subprocess.run(
            [
                "ghc",
                "-O2",
                "-outputdir",
                tmp,
                "-o",
                hs_bin,
                os.path.join(here, "solution.hs"),
                os.path.join(here, "Test.hs"),
            ],
            cwd=here,
            check=True,
            capture_output=True,
            text=True,
        )
        res_hs = subprocess.run([hs_bin], cwd=here, check=True, capture_output=True, text=True)
        print(res_hs.stdout.strip())
