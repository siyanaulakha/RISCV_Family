# Single-Cycle RV32I Baseline Verification

Date: 2026-07-30

## Environment

- Icarus Verilog 14.0 development build
- Verilator 5.051 development build
- Yosys from OSS CAD Suite
- Ubuntu Linux

## Results

| Check | Result |
|---|---:|
| Smoke program | PASS |
| Final smoke-test PC | `0x0000004c` |
| Directed branch regression | 12/12 PASS |
| Structural repository audit | PASS, 0 warnings |
| Verilator lint | PASS with non-blocking unused-bit warnings |
| Yosys hierarchy, process conversion, optimization and structural check | PASS |

## Branch coverage

The directed regression covers:

- BEQ
- BNE
- BLT
- BGE
- BLTU
- BGEU

Signed and unsigned boundary cases include `0x80000000`, `0x7fffffff`
and `0xffffffff`.

## Known non-blocking warnings

The instruction-memory test image contains fewer words than the configured
512-word memory. Verilator also reports intentionally unused address and
instruction bits caused by local-memory indexing and instruction decoding.
