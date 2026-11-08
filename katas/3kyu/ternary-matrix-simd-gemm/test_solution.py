#!/usr/bin/env python3
"""End-to-end multi-language verification runner for Ternary Matrix SIMD Contraction (3 kyu)."""

import os
import shutil
import subprocess
import tempfile

if __name__ == "__main__":
    here = os.path.dirname(os.path.abspath(__file__))
    with tempfile.TemporaryDirectory() as tmp:
        # 1. Verify x86-64 NASM SIMD assembly syntax & ELF64 object generation (when nasm is installed)
        if shutil.which("nasm"):
            x86_obj = os.path.join(tmp, "solution_x86_64.o")
            subprocess.run(
                ["nasm", "-f", "elf64", "-w+error", os.path.join(here, "solution.asm"), "-o", x86_obj],
                cwd=here,
                check=True,
            )

        # 2. Verify native Apple Silicon AArch64 NEON SIMD assembly (`solution_arm64.s`)
        asm_bin = os.path.join(tmp, "test_asm")
        subprocess.run(
            [
                "clang++",
                "-std=c++20",
                "-O3",
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

        # 3. Verify Rust NEON SIMD + exact p/q + SPQT Base-243 (`solution.rs`)
        rs_bin = os.path.join(tmp, "solution_rs")
        subprocess.run(
            ["rustc", "-O", os.path.join(here, "solution.rs"), "-o", rs_bin],
            cwd=here,
            check=True,
        )
        res_rs = subprocess.run([rs_bin], cwd=here, check=True, capture_output=True, text=True)
        print(res_rs.stdout.strip())

        # 4. Verify SWI-Prolog relational oracle (`solution.pl` + `test.pl`)
        res_pl = subprocess.run(
            ["swipl", "-q", "-g", "run_tests", "-t", "halt", os.path.join(here, "test.pl")],
            cwd=here,
            check=True,
            capture_output=True,
            text=True,
        )
        print("ALL SWI-PROLOG TERNARY_MATRIX_SIMD_GEMM SUITES PASSED!")
