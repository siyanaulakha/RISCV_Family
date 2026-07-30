# Five-Stage Pipelined RISC-V RV32I Processor

A Verilog implementation of a five-stage RV32I processor with IF/ID, ID/EX, EX/MEM, and MEM/WB pipeline registers, data forwarding, a load-use interlock, and control-hazard flushing.

Developed collaboratively by **Siya Naulakha** and **Aaditya Chavan**. The cleanup and verification candidate adds reproducible open-source regression, lint, and synthesis flows while retaining the original history and legacy Vivado material.

## Implemented scope

- RV32I integer ALU and immediate instructions used by the supplied architectural program
- byte, halfword, and word loads/stores
- BEQ, BNE, BLT, BGE, BLTU, and BGEU
- JAL and JALR
- LUI and AUIPC
- EX/MEM and MEM/WB forwarding
- forwarded store data
- load-use stalling
- taken-branch and jump flushing
- JALR target bit-zero clearing

The design does **not** implement RV32M multiplication/division, CSRs, privilege modes, exceptions, interrupts, caches, or formal RISC-V compliance.

## Reproducible checks

Activate an RTL toolchain containing Icarus Verilog, Verilator, and Yosys, then run:

```bash
make test
make lint
make synth
```

Or run all checks:

```bash
make all
```

The test matrix is documented in [`docs/verification.md`](docs/verification.md).

## Source layout

- `sources_1/new/`: synthesizable processor RTL
- `tb/`: self-checking open-source testbenches
- `rv32i_test.hex`: original architectural test program
- `hazard_test.hex`: focused forwarding/stall/flush program
- `sim_1/new/tb.v`: retained legacy Vivado testbench; not used by `make test`
- `docs/`: verification and provenance notes

## Important status note

This ZIP is a **repair candidate produced from static source audit**. Its regressions must be executed with the local OSS CAD Suite or GitHub Actions before the candidate is merged or used for quantified resume claims.
