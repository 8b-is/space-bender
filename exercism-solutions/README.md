# Exercism Assembly Solutions for 8b-is Training

This directory contains solutions to Exercism assembly exercises, collected for training AI models on assembly programming patterns.

## Structure

```
exercism-solutions/
├── arm64-assembly/
│   └── hello-world/
│       └── hello_world.s       # ARM64 (macOS/Linux) solution
└── x86-64-assembly/
    └── hello-world/
        └── hello_world.asm     # x86-64 (NASM/ELF64) solution
```

## Solutions

### ARM64 Assembly (hello-world)

**File:** `arm64-assembly/hello-world/hello_world.s`

```assembly
.section __TEXT,__cstring,cstring_literals
msg: .asciz "Hello, World!"

.section __TEXT,__text
.global _hello
_hello:
        adrp    x0, msg@PAGE
        add     x0, x0, msg@PAGEOFF
        ret
```

**Tested on:** macOS ARM64 (Apple Silicon) with Clang
**Status:** ✅ Passes test (`hello()` returns "Hello, World!")

### x86-64 Assembly (hello-world)

**File:** `x86-64-assembly/hello-world/hello_world.asm`

```nasm
default rel

section .data
msg: db "Hello, World!", 0

section .text
global _hello
_hello:
    lea rax, [msg]
    ret
```

**Tested on:** Linux x86-64 (via Exercism CI)
**Status:** ✅ Submitted to Exercism

## Usage for Training

These solutions can be used to train AI models on:
- Assembly syntax (ARM64/GAS vs x86-64/NASM)
- Calling conventions (AAPCS64 vs System V AMD64 ABI)
- Position-independent code patterns
- String handling in assembly
- Cross-platform assembly differences

## Exercism Tracks

- ARM64 Assembly: https://exercism.org/tracks/arm64-assembly
- x86-64 Assembly: https://exercism.org/tracks/x86-64-assembly

## Collection Date

Collected: 2026-11-10
Collector: Peter Lodri (∞) / 8b-is constellation
