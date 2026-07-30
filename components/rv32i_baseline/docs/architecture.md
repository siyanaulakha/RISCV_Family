# Architecture

## Current verified baseline

This repository contains a modular, non-pipelined educational RV32I processor implemented in Verilog.

## Main modules

- `RISC_V_IM.v` — processor, instruction-memory, and data-memory integration
- `riscv_cpu.v` — controller and datapath integration
- `controller.v` — main control and ALU-control integration
- `main_decoder.v` — opcode and conditional-branch decoding
- `alu_decoder.v` — ALU-operation decoding
- `datapath.v` — program counter, register file, ALU, immediate path, and result selection
- `alu.v` — arithmetic, logical, shift, signed comparison, and unsigned comparison operations
- `reg_file.v` — integer register file
- `instr_mem.v` — instruction memory
- `data_mem.v` — byte, halfword, and word data-memory operations
- `imm_extend.v` — immediate generation
- `adder.v`, `mux2.v`, `mux4.v`, `reset_ff.v` — reusable datapath components

## Branch-comparison path

The verified branch implementation uses:

- subtraction and the `Zero` flag for `BEQ` and `BNE`;
- signed `SLT` for `BLT` and `BGE`;
- unsigned `SLTU` for `BLTU` and `BGEU`.

The datapath returns the comparison result through the `LessThan` signal. The directed branch regression covers all six branch instructions and includes signed-overflow-sensitive and signed-versus-unsigned corner cases.

## Memory organization

The default data memory contains 64 words.

- Address bits `[7:2]` select the local data-memory word.
- Address bits `[1:0]` select byte or halfword lanes.
- Unsupported or misaligned local-memory reads return zero.
- Unsupported or misaligned stores perform no write.

The instruction memory contains 512 words and uses the word-aligned instruction-address bits `[10:2]`.

## Current verification evidence

- Structural repository audit: PASS
- Integrated smoke simulation: PASS
- Smoke-test final PC: `0x0000004c`
- Directed branch regression: 12/12 PASS
- Verilator lint: no errors
- Yosys RTL synthesis and hierarchy checks: PASS

## Features not evidenced in this repository

This baseline does not currently claim:

- a five-stage pipeline;
- pipeline-stage registers;
- forwarding logic;
- hazard detection or pipeline stalls;
- branch flushing;
- multiplication or division;
- the RISC-V `M` extension;
- exceptions or interrupts;
- privileged execution;
- caches or virtual memory;
- formal RISC-V architectural compliance.

More advanced processor and fault-tolerant revisions should remain separate until their RTL and verification evidence are reviewed.
