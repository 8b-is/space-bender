#!/usr/bin/env python3
"""Verification suite for Hamming Numbers (4 kyu, NASM x86-64, 526d84b98f428f14a60008da).

Assembles `solution.asm` with `nasm -f elf64`, parses the ELF64 `.text`, `.bss`,
and `.rela.text` sections, relocates `.bss` references (`R_X86_64_PC32`), and
executes the actual x86-64 machine-code bytes produced by NASM across all
1 <= n <= 13,282.
"""

from __future__ import annotations

import os
import struct
import subprocess
import tempfile

MAX_N = 13282
MASK64 = (1 << 64) - 1
MASK32 = (1 << 32) - 1


def reference_hamming(limit: int = MAX_N) -> list[int]:
    """Generate the first `limit` Hamming numbers (2^i * 3^j * 5^k)."""
    h = [1] * limit
    i2 = i3 = i5 = 0
    x2, x3, x5 = 2, 3, 5
    for k in range(1, limit):
        m = min(x2, x3, x5)
        h[k] = m
        if m == x2:
            i2 += 1
            x2 = h[i2] * 2
        if m == x3:
            i3 += 1
            x3 = h[i3] * 3
        if m == x5:
            i5 += 1
            x5 = h[i5] * 5
    return h


class X86_64Runner:
    """Minimal cycle-accurate x86-64 ELF64 machine-code runner for `solution.o`."""

    def __init__(self, obj_path: str) -> None:
        with open(obj_path, "rb") as f:
            elf = f.read()

        if elf[:4] != b"\x7fELF" or elf[4] != 2 or elf[5] != 1:
            raise ValueError("Expected 64-bit little-endian ELF object")

        e_shoff = struct.unpack_from("<Q", elf, 0x28)[0]
        e_shentsize, e_shnum, e_shstrndx = struct.unpack_from("<HHH", elf, 0x3A)

        sections = []
        for i in range(e_shnum):
            off = e_shoff + i * e_shentsize
            sh = struct.unpack_from("<IIQQQQIIQQ", elf, off)
            sections.append(sh)

        shstr_off = sections[e_shstrndx][4]
        shstr_size = sections[e_shstrndx][5]
        shstrtab = elf[shstr_off : shstr_off + shstr_size]

        def sec_name(name_idx: int) -> str:
            end = shstrtab.find(b"\x00", name_idx)
            return shstrtab[name_idx:end].decode("ascii")

        sec_by_name = {}
        for idx, sh in enumerate(sections):
            sec_by_name[sec_name(sh[0])] = (idx, sh)

        _, text_sh = sec_by_name[".text"]
        _, bss_sh = sec_by_name[".bss"]
        text_bytes = bytearray(elf[text_sh[4] : text_sh[4] + text_sh[5]])
        bss_size = bss_sh[5]

        # Verify exported symbols `hamming` and `hamber` in `.symtab`
        _, sym_sh = sec_by_name[".symtab"]
        _, str_sh = sec_by_name[".strtab"]
        strtab = elf[str_sh[4] : str_sh[4] + str_sh[5]]
        global_syms = set()
        for off in range(sym_sh[4], sym_sh[4] + sym_sh[5], 24):
            st_name, st_info, _, st_shndx, st_value, _ = struct.unpack_from("<IBBHQQ", elf, off)
            if (st_info >> 4) == 1:  # STB_GLOBAL
                end = strtab.find(b"\x00", st_name)
                global_syms.add(strtab[st_name:end].decode("ascii"))
        assert "hamming" in global_syms, f"missing global hamming in {global_syms}"
        assert "hamber" in global_syms, f"missing global hamber in {global_syms}"

        # Layout: .text at 0x0000, .bss at 0x1000, stack at top
        self.text_base = 0x0000
        self.bss_base = 0x1000
        self.stack_base = 0x40000
        self.mem = bytearray(self.stack_base + 0x1000)

        # Apply .rela.text relocations
        if ".rela.text" in sec_by_name:
            _, rela_sh = sec_by_name[".rela.text"]
            for off in range(rela_sh[4], rela_sh[4] + rela_sh[5], 24):
                r_offset, r_info, r_addend = struct.unpack_from("<QQq", elf, off)
                r_type = r_info & 0xFFFFFFFF
                assert r_type == 2, f"Unsupported relocation type {r_type}"  # R_X86_64_PC32
                rel32 = (self.bss_base + r_addend) - (self.text_base + r_offset)
                struct.pack_into("<i", text_bytes, r_offset, rel32)

        self.code_len = len(text_bytes)
        self.mem[self.text_base : self.text_base + self.code_len] = text_bytes
        assert bss_size >= MAX_N * 8, f"Expected .bss >= {MAX_N * 8} bytes, got {bss_size}"

    def call_hamming(self, n: int) -> tuple[int, int]:
        """Invoke `hamming(n)` on the relocated x86-64 machine code; returns (rax, steps)."""
        # Registers: 0:rax, 1:rcx, 2:rdx, 3:rbx, 4:rsp, 5:rbp, 6:rsi, 7:rdi, 8..15:r8..r15
        reg = [0] * 16
        reg[7] = n & MASK32  # edi = n
        reg[4] = self.stack_base
        rip = self.text_base
        cf = False
        zf = False
        steps = 0
        mem = self.mem

        while True:
            steps += 1
            b0 = mem[rip]

            # 89 ff -> mov edi, edi
            if b0 == 0x89 and mem[rip + 1] == 0xFF:
                reg[7] &= MASK32
                rip += 2
            # 4c 8d 05 disp32 -> lea r8, [rip + disp32]
            elif b0 == 0x4C and mem[rip + 1] == 0x8D and mem[rip + 2] == 0x05:
                disp = struct.unpack_from("<i", mem, rip + 3)[0]
                rip += 7
                reg[8] = (rip + disp) & MASK64
            # 49 83 38 00 -> cmp qword [r8], 0
            elif b0 == 0x49 and mem[rip + 1] == 0x83 and mem[rip + 2] == 0x38:
                imm = struct.unpack_from("<b", mem, rip + 3)[0] & MASK64
                val = struct.unpack_from("<Q", mem, reg[8])[0]
                cf = val < imm
                zf = val == imm
                rip += 4
            # 74 rel8 -> je rel8
            elif b0 == 0x74:
                rel = struct.unpack_from("<b", mem, rip + 1)[0]
                rip += 2
                if zf:
                    rip += rel
            # 75 rel8 -> jne rel8
            elif b0 == 0x75:
                rel = struct.unpack_from("<b", mem, rip + 1)[0]
                rip += 2
                if not zf:
                    rip += rel
            # 72 rel8 -> jb rel8
            elif b0 == 0x72:
                rel = struct.unpack_from("<b", mem, rip + 1)[0]
                rip += 2
                if cf:
                    rip += rel
            # 49 8b 44 f8 f8 -> mov rax, [r8 + rdi*8 - 8]
            elif b0 == 0x49 and mem[rip + 1] == 0x8B and mem[rip + 2] == 0x44 and mem[rip + 3] == 0xF8:
                disp = struct.unpack_from("<b", mem, rip + 4)[0]
                addr = reg[8] + reg[7] * 8 + disp
                reg[0] = struct.unpack_from("<Q", mem, addr)[0]
                rip += 5
            # c3 -> ret
            elif b0 == 0xC3:
                return reg[0], steps
            # 57 -> push rdi
            elif b0 == 0x57:
                reg[4] -= 8
                struct.pack_into("<Q", mem, reg[4], reg[7])
                rip += 1
            # 5f -> pop rdi
            elif b0 == 0x5F:
                reg[7] = struct.unpack_from("<Q", mem, reg[4])[0]
                reg[4] += 8
                rip += 1
            # 49 c7 00 imm32 -> mov qword [r8], imm32
            elif b0 == 0x49 and mem[rip + 1] == 0xC7 and mem[rip + 2] == 0x00:
                imm = struct.unpack_from("<i", mem, rip + 3)[0] & MASK64
                struct.pack_into("<Q", mem, reg[8], imm)
                rip += 7
            # b9 imm32 -> mov ecx, imm32
            elif b0 == 0xB9:
                reg[1] = struct.unpack_from("<I", mem, rip + 1)[0]
                rip += 5
            # bf imm32 -> mov edi, imm32
            elif b0 == 0xBF:
                reg[7] = struct.unpack_from("<I", mem, rip + 1)[0]
                rip += 5
            # 31 f6 -> xor esi, esi
            elif b0 == 0x31 and mem[rip + 1] == 0xF6:
                reg[6] = 0
                cf = False
                zf = True
                rip += 2
            # 31 d2 -> xor edx, edx
            elif b0 == 0x31 and mem[rip + 1] == 0xD2:
                reg[2] = 0
                cf = False
                zf = True
                rip += 2
            # 45 31 c9 -> xor r9d, r9d
            elif b0 == 0x45 and mem[rip + 1] == 0x31 and mem[rip + 2] == 0xC9:
                reg[9] = 0
                cf = False
                zf = True
                rip += 3
            # 41 ba imm32 -> mov r10d, imm32
            elif b0 == 0x41 and mem[rip + 1] == 0xBA:
                reg[10] = struct.unpack_from("<I", mem, rip + 2)[0]
                rip += 6
            # 41 bb imm32 -> mov r11d, imm32
            elif b0 == 0x41 and mem[rip + 1] == 0xBB:
                reg[11] = struct.unpack_from("<I", mem, rip + 2)[0]
                rip += 6
            # 4c 89 d0 -> mov rax, r10
            elif b0 == 0x4C and mem[rip + 1] == 0x89 and mem[rip + 2] == 0xD0:
                reg[0] = reg[10]
                rip += 3
            # 49 39 c3 -> cmp r11, rax
            elif b0 == 0x49 and mem[rip + 1] == 0x39 and mem[rip + 2] == 0xC3:
                cf = reg[11] < reg[0]
                zf = reg[11] == reg[0]
                rip += 3
            # 49 0f 42 c3 -> cmovb rax, r11
            elif b0 == 0x49 and mem[rip + 1] == 0x0F and mem[rip + 2] == 0x42 and mem[rip + 3] == 0xC3:
                if cf:
                    reg[0] = reg[11]
                rip += 4
            # 48 39 c7 -> cmp rdi, rax
            elif b0 == 0x48 and mem[rip + 1] == 0x39 and mem[rip + 2] == 0xC7:
                cf = reg[7] < reg[0]
                zf = reg[7] == reg[0]
                rip += 3
            # 48 0f 42 c7 -> cmovb rax, rdi
            elif b0 == 0x48 and mem[rip + 1] == 0x0F and mem[rip + 2] == 0x42 and mem[rip + 3] == 0xC7:
                if cf:
                    reg[0] = reg[7]
                rip += 4
            # 49 89 04 c8 -> mov [r8 + rcx*8], rax
            elif b0 == 0x49 and mem[rip + 1] == 0x89 and mem[rip + 2] == 0x04 and mem[rip + 3] == 0xC8:
                struct.pack_into("<Q", mem, reg[8] + reg[1] * 8, reg[0])
                rip += 4
            # 4c 39 d0 -> cmp rax, r10
            elif b0 == 0x4C and mem[rip + 1] == 0x39 and mem[rip + 2] == 0xD0:
                cf = reg[0] < reg[10]
                zf = reg[0] == reg[10]
                rip += 3
            # ff c6 -> inc esi
            elif b0 == 0xFF and mem[rip + 1] == 0xC6:
                reg[6] = (reg[6] + 1) & MASK32
                zf = reg[6] == 0
                rip += 2
            # 4d 8b 14 f0 -> mov r10, [r8 + rsi*8]
            elif b0 == 0x4D and mem[rip + 1] == 0x8B and mem[rip + 2] == 0x14 and mem[rip + 3] == 0xF0:
                reg[10] = struct.unpack_from("<Q", mem, reg[8] + reg[6] * 8)[0]
                rip += 4
            # 4d 01 d2 -> add r10, r10
            elif b0 == 0x4D and mem[rip + 1] == 0x01 and mem[rip + 2] == 0xD2:
                s = reg[10] + reg[10]
                cf = s > MASK64
                reg[10] = s & MASK64
                zf = reg[10] == 0
                rip += 3
            # 4c 39 d8 -> cmp rax, r11
            elif b0 == 0x4C and mem[rip + 1] == 0x39 and mem[rip + 2] == 0xD8:
                cf = reg[0] < reg[11]
                zf = reg[0] == reg[11]
                rip += 3
            # ff c2 -> inc edx
            elif b0 == 0xFF and mem[rip + 1] == 0xC2:
                reg[2] = (reg[2] + 1) & MASK32
                zf = reg[2] == 0
                rip += 2
            # 4d 8b 1c d0 -> mov r11, [r8 + rdx*8]
            elif b0 == 0x4D and mem[rip + 1] == 0x8B and mem[rip + 2] == 0x1C and mem[rip + 3] == 0xD0:
                reg[11] = struct.unpack_from("<Q", mem, reg[8] + reg[2] * 8)[0]
                rip += 4
            # 4f 8d 1c 5b -> lea r11, [r11 + r11*2]
            elif b0 == 0x4F and mem[rip + 1] == 0x8D and mem[rip + 2] == 0x1C and mem[rip + 3] == 0x5B:
                reg[11] = (reg[11] * 3) & MASK64
                rip += 4
            # 48 39 f8 -> cmp rax, rdi
            elif b0 == 0x48 and mem[rip + 1] == 0x39 and mem[rip + 2] == 0xF8:
                cf = reg[0] < reg[7]
                zf = reg[0] == reg[7]
                rip += 3
            # 41 ff c1 -> inc r9d
            elif b0 == 0x41 and mem[rip + 1] == 0xFF and mem[rip + 2] == 0xC1:
                reg[9] = (reg[9] + 1) & MASK32
                zf = reg[9] == 0
                rip += 3
            # 4b 8b 3c c8 -> mov rdi, [r8 + r9*8]
            elif b0 == 0x4B and mem[rip + 1] == 0x8B and mem[rip + 2] == 0x3C and mem[rip + 3] == 0xC8:
                reg[7] = struct.unpack_from("<Q", mem, reg[8] + reg[9] * 8)[0]
                rip += 4
            # 48 8d 3c bf -> lea rdi, [rdi + rdi*4]
            elif b0 == 0x48 and mem[rip + 1] == 0x8D and mem[rip + 2] == 0x3C and mem[rip + 3] == 0xBF:
                reg[7] = (reg[7] * 5) & MASK64
                rip += 4
            # ff c1 -> inc ecx
            elif b0 == 0xFF and mem[rip + 1] == 0xC1:
                reg[1] = (reg[1] + 1) & MASK32
                zf = reg[1] == 0
                rip += 2
            # 81 f9 imm32 -> cmp ecx, imm32
            elif b0 == 0x81 and mem[rip + 1] == 0xF9:
                imm = struct.unpack_from("<I", mem, rip + 2)[0]
                cf = reg[1] < imm
                zf = reg[1] == imm
                rip += 6
            else:
                opcode_hex = mem[rip : rip + 8].hex(" ")
                raise RuntimeError(f"Unrecognized x86-64 opcode at RIP={rip:#x}: {opcode_hex}")


def main() -> None:
    here = os.path.dirname(os.path.abspath(__file__))
    sol_asm = os.path.join(here, "solution.asm")

    with tempfile.TemporaryDirectory() as tmp:
        obj_path = os.path.join(tmp, "solution.o")
        subprocess.run(["nasm", "-f", "elf64", "-w+error", sol_asm, "-o", obj_path], check=True)
        runner = X86_64Runner(obj_path)

    expected = reference_hamming(MAX_N)

    # 1. Verify the 20 smallest Hamming numbers from the Codewars example fixture
    first_20 = [1, 2, 3, 4, 5, 6, 8, 9, 10, 12, 15, 16, 18, 20, 24, 25, 27, 30, 32, 36]
    for idx, exp in enumerate(first_20, start=1):
        got, steps = runner.call_hamming(idx)
        assert got == exp, f"hamming({idx}) = {got}, expected {exp}"
        if idx > 1:
            assert steps == 6, f"Expected 6-instruction O(1) fast path on cached call #{idx}, took {steps}"

    # 2. Verify all 13,282 Hamming numbers (1 <= n <= 13,282)
    for n in range(1, MAX_N + 1):
        got, steps = runner.call_hamming(n)
        exp = expected[n - 1]
        assert got == exp, f"hamming({n}) = {got}, expected {exp}"
        assert steps == 6, f"Expected 6-instruction O(1) lookup for n={n}, got {steps}"

    # 3. Verify landmark values
    assert runner.call_hamming(1691)[0] == 2125764000
    assert runner.call_hamming(5000)[0] == 50837316566580
    assert runner.call_hamming(13282)[0] == 18432000000000000000

    print(f"ALL {MAX_N} HAMMING NUMBERS PASS (hamming(13282) = {expected[-1]}, .text = {runner.code_len} bytes)")


if __name__ == "__main__":
    main()
