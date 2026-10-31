#!/usr/bin/env python3
"""Verification runner for Range Extraction (4 kyu, Haskell + Julia + x86-64 NASM + AArch64 ASM, 51ba717bb08c1cd60f00002f)."""

import os
import shutil
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

        # 2. Verify native AArch64 assembly on Apple Silicon
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

        # 3. Verify Haskell (`solution.hs`) via GHC
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

        # 4. Verify Julia (`solution.jl`)
        julia_bin = shutil.which("julia")
        if not julia_bin and os.path.exists("/Applications/Julia-1.13.app/Contents/Resources/julia/bin/julia"):
            julia_bin = "/Applications/Julia-1.13.app/Contents/Resources/julia/bin/julia"
        if julia_bin:
            jl_code = f"""
            include({os.path.join(here, "solution.jl")!r})
            using .Solution
            @assert rangeextraction([-6,-3,-2,-1,0,1,3,4,5,7,8,9,10,11,14,15,17,18,19,20]) == "-6,-3-1,3-5,7-11,14,15,17-20"
            @assert rangeextraction([-10,-9,-8,-6,-3,-2,-1,0,1,3,4,5,7,8,9,10,11,14,15,17,18,19,20]) == "-10--8,-6,-3-1,3-5,7-11,14,15,17-20"
            @assert rangeextraction([-3,-2,-1,2,10,15,16,18,19,20]) == "-3--1,2,10,15,16,18-20"
            @assert rangeextraction([1,2,3,4,5]) == "1-5"
            @assert rangeextraction([1,2,4,5]) == "1,2,4,5"
            @assert rangeextraction([42]) == "42"
            @assert rangeextraction(Int[]) == ""
            println("ALL JULIA RANGE_EXTRACTION SUITES PASSED!")
            """
            res_jl = subprocess.run([julia_bin, "-e", jl_code], cwd=here, check=True, capture_output=True, text=True)
            print(res_jl.stdout.strip())
