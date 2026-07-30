#!/usr/bin/env python3
from __future__ import annotations
import re
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
RTL = ROOT / "sources_1" / "new"
REQUIRED = [
    "t1c_riscv_cpu.v", "riscv_cpu.v", "controller.v", "main_decoder.v",
    "alu_decoder.v", "datapath.v", "branch_compare.v", "HAZARD_UNIT.v",
    "IF_PL_REG.v", "DE_PL_REG.v", "MW_PL_REG.v", "WB_PL_REG.v",
    "alu.v", "reg_file.v", "instr_mem.v", "data_mem.v", "imm_extend.v",
    "adder.v", "mux2.v", "mux3.v", "mux4.v", "reset_ff.v",
]


def strip_comments(text: str) -> str:
    text = re.sub(r"/\*.*?\*/", "", text, flags=re.S)
    return re.sub(r"//.*", "", text)


def main() -> int:
    errors: list[str] = []
    warnings: list[str] = []

    for name in REQUIRED:
        path = RTL / name
        if not path.is_file():
            errors.append(f"missing RTL file: {path.relative_to(ROOT)}")
            continue
        text = path.read_text(errors="replace")
        clean = strip_comments(text)
        modules = len(re.findall(r"\bmodule\b", clean))
        endmodules = len(re.findall(r"\bendmodule\b", clean))
        if modules != endmodules:
            errors.append(f"{name}: module/endmodule mismatch {modules}/{endmodules}")
        if "$display" in clean or "$monitor" in clean or "$stop" in clean:
            errors.append(f"{name}: simulation-only system task remains in synthesizable RTL")
        if re.search(r"\bWB_PL_REG\s+\w+\s*\(\s*clk\s*,\s*rst\b", clean):
            errors.append(f"{name}: legacy undriven 'rst' connection remains")

    for program, expected_words in [("rv32i_test.hex", 79), ("hazard_test.hex", 22)]:
        path = ROOT / program
        if not path.is_file():
            errors.append(f"missing program image: {program}")
            continue
        words = [line.strip() for line in path.read_text().splitlines()
                 if line.strip() and not line.lstrip().startswith(("#", "//", "@"))]
        if len(words) != expected_words:
            errors.append(f"{program}: expected {expected_words} words, found {len(words)}")
        bad = [word for word in words if not re.fullmatch(r"[0-9a-fA-F]{8}", word)]
        if bad:
            errors.append(f"{program}: malformed 32-bit words: {bad[:3]}")

    legacy = ROOT / "sim_1" / "new" / "tb.v"
    if legacy.exists():
        warnings.append("legacy print-oriented Vivado testbench retained under sim_1/new; it is not part of make test")

    if not (ROOT / "README.md").is_file():
        errors.append("README.md missing")

    print("Pipelined RV32I structural audit")
    print(f"root={ROOT}")
    for item in warnings:
        print(f"WARNING: {item}")
    for item in errors:
        print(f"ERROR: {item}")
    if errors:
        print(f"FAIL: {len(errors)} error(s), {len(warnings)} warning(s)")
        return 1
    print(f"PASS: structural checks complete ({len(warnings)} warning(s))")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
