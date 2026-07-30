# RISC-V RV32I Processor RTL

A modular educational RV32I processor implemented in Verilog for RTL simulation, linting, synthesis, and FPGA-oriented experimentation.

## Verified status

- Integrated smoke simulation: **PASS**
- Smoke-test final PC: `0x0000004c`
- Directed branch regression: **12/12 checks passed**
- Branches tested: `BEQ`, `BNE`, `BLT`, `BGE`, `BLTU`, and `BGEU`
- Verilator lint: no errors
- Yosys RTL synthesis and hierarchy checks: PASS

## Current scope

The repository includes:

- processor controller and datapath;
- integer ALU and register file;
- immediate and instruction decoding;
- branch, JAL, and JALR control;
- instruction and data memories;
- byte, halfword, and word memory operations;
- automated smoke and branch-directed tests.

The current public RTL does **not** claim:

- a five-stage pipeline;
- forwarding or hazard-control logic;
- the RISC-V `M` extension;
- privileged execution;
- formal RISC-V architectural compliance.

## Running the checks

Activate OSS CAD Suite:

    source "$HOME/tools/eda/oss-cad-suite/environment"

Run the functional regressions:

    make test

Run lint and generic synthesis:

    make lint
    make synth

Run everything:

    make all

## Verification limits

The smoke test confirms integrated execution and a known program-counter trajectory.

The branch regression verifies signed and unsigned comparison/control behavior, including signed-overflow-sensitive corner cases.

Additional tests are still required for complete ALU, register-file, memory, jump, and program-level behavior.

## Archived source

The original source archive is preserved outside this Git repository under:

    ~/research/archive/riscv-original/
