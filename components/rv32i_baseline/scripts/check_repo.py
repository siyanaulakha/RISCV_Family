#!/usr/bin/env python3
"""Fail-fast structural audit for the public RISC-V RTL repository."""
from __future__ import annotations

import re
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
REQUIRED = [
    "RISC_V_IM.v", "riscv_cpu.v", "controller.v", "datapath.v",
    "main_decoder.v", "alu_decoder.v", "alu.v", "reg_file.v",
    "instr_mem.v", "data_mem.v", "imm_extend.v", "adder.v",
    "mux2.v", "mux4.v", "reset_ff.v", "rv32i_test.hex",
]
EXPECTED_MODULES = {
    "RISC_V_IM.v": "RISC_V_IM",
    "riscv_cpu.v": "riscv_cpu",
    "controller.v": "controller",
    "datapath.v": "datapath",
}


def main() -> int:
    errors: list[str] = []
    warnings: list[str] = []

    for rel in REQUIRED:
        path = ROOT / rel
        if not path.is_file():
            errors.append(f"missing required file: {rel}")
            continue
        if path.stat().st_size == 0:
            errors.append(f"empty required file: {rel}")

    for rel, module in EXPECTED_MODULES.items():
        path = ROOT / rel
        if not path.is_file():
            continue
        text = path.read_text(encoding="utf-8", errors="replace")
        if not re.search(rf"\bmodule\s+{re.escape(module)}\b", text):
            errors.append(f"{rel}: expected module '{module}' not found")

    archives = sorted(p.name for p in ROOT.iterdir() if p.suffix.lower() in {".rar", ".zip", ".7z"})
    if archives:
        warnings.append("source archives should be removed from the repository: " + ", ".join(archives))

    if not (ROOT / "README.md").is_file():
        errors.append("README.md is missing")

    print("RISC-V repository structural audit")
    print(f"root={ROOT}")
    for warning in warnings:
        print(f"WARNING: {warning}")
    for error in errors:
        print(f"ERROR: {error}")

    if errors:
        print(f"FAIL: {len(errors)} error(s), {len(warnings)} warning(s)")
        return 1
    print(f"PASS: structural checks complete ({len(warnings)} warning(s))")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
