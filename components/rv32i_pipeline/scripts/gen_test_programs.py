#!/usr/bin/env python3
"""Generate deterministic RV32I programs used by the RTL regressions."""
from __future__ import annotations
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]

def check_signed(value: int, bits: int) -> int:
    lo = -(1 << (bits - 1)); hi = (1 << (bits - 1)) - 1
    if not lo <= value <= hi:
        raise ValueError(f"{value} does not fit signed {bits}-bit immediate")
    return value & ((1 << bits) - 1)

def i_type(imm: int, rs1: int, funct3: int, rd: int, opcode: int = 0x13) -> int:
    imm = check_signed(imm, 12)
    return (imm << 20) | (rs1 << 15) | (funct3 << 12) | (rd << 7) | opcode

def r_type(funct7: int, rs2: int, rs1: int, funct3: int, rd: int) -> int:
    return (funct7 << 25) | (rs2 << 20) | (rs1 << 15) | (funct3 << 12) | (rd << 7) | 0x33

def s_type(imm: int, rs2: int, rs1: int, funct3: int) -> int:
    imm = check_signed(imm, 12)
    return ((imm >> 5) << 25) | (rs2 << 20) | (rs1 << 15) | (funct3 << 12) | ((imm & 0x1f) << 7) | 0x23

def b_type(offset: int, rs2: int, rs1: int, funct3: int) -> int:
    if offset & 1:
        raise ValueError("branch offset must be 2-byte aligned")
    imm = check_signed(offset, 13)
    return (((imm >> 12) & 1) << 31) | (((imm >> 5) & 0x3f) << 25) | (rs2 << 20) | (rs1 << 15) | (funct3 << 12) | (((imm >> 1) & 0xf) << 8) | (((imm >> 11) & 1) << 7) | 0x63

def u_type(imm20: int, rd: int, opcode: int) -> int:
    return ((imm20 & 0xfffff) << 12) | (rd << 7) | opcode

def j_type(offset: int, rd: int) -> int:
    if offset & 1:
        raise ValueError("JAL offset must be 2-byte aligned")
    imm = check_signed(offset, 21)
    return (((imm >> 20) & 1) << 31) | (((imm >> 1) & 0x3ff) << 21) | (((imm >> 11) & 1) << 20) | (((imm >> 12) & 0xff) << 12) | (rd << 7) | 0x6f

def write_hex(name: str, words: list[int]) -> None:
    path = ROOT / name
    path.write_text("".join(f"{word:08x}\n" for word in words))
    print(f"wrote {path} ({len(words)} instructions)")

# Forwarding, load-use interlock, store-data forwarding, branch/JAL/JALR
# flushing, LUI/AUIPC forwarding, and JALR bit-zero clearing.
hazard = [
    i_type(5, 0, 0, 1),                 # addi x1,x0,5
    r_type(0, 1, 1, 0, 2),              # add  x2,x1,x1
    r_type(0, 1, 2, 0, 3),              # add  x3,x2,x1
    s_type(0, 3, 0, 2),                 # sw   x3,0(x0)
    i_type(0, 0, 2, 4, 0x03),           # lw   x4,0(x0)
    r_type(0, 1, 4, 0, 5),              # add  x5,x4,x1
    i_type(20, 0, 0, 7),                # addi x7,x0,20
    b_type(8, 7, 5, 0),                 # beq  x5,x7,+8
    i_type(1, 0, 0, 6),                 # flushed
    i_type(2, 0, 0, 6),                 # x6=2
    u_type(0x12345, 8, 0x37),            # lui  x8,0x12345
    i_type(1, 8, 0, 9),                 # addi x9,x8,1
    u_type(0x1, 10, 0x17),               # auipc x10,0x1 (PC=48)
    i_type(1, 10, 0, 11),               # addi x11,x10,1
    j_type(8, 12),                       # jal x12,+8
    i_type(1, 0, 0, 13),                # flushed
    i_type(2, 0, 0, 13),                # x13=2
    i_type(81, 0, 0, 14),               # odd target address
    i_type(0, 14, 0, 15, 0x67),         # jalr x15,0(x14) -> 80
    i_type(1, 0, 0, 16),                # flushed
    i_type(2, 0, 0, 16),                # x16=2
    j_type(0, 0),                        # halt loop
]
write_hex("hazard_test.hex", hazard)
