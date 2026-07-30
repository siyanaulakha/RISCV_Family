# Import Provenance

- Current source repository: `git@github.com:siyanaulakha/Pipelined_RISC-V_RV32I.git`
- Collaborative source remote: `https://github.com/Aadityaaaaaa12/Pipelined_RISC-V_RV32I.git`
- Original repository commit at import time: `23f6fd6fdd9880ab83f0c7c59f01a2119abe4788`
- Verified candidate source:
  `/home/zira/Downloads/riscv_family_delivery/candidates/Pipelined_RISC-V_RV32I-clean-candidate`
- Import date: 2026-07-30
- Unified path: `components/rv32i_pipeline`

## Development history

The five-stage pipelined RV32I processor was developed collaboratively. Its
original Git history and contributor authorship remain preserved in the source
repositories.

The original implementation was demonstrated on a Terasic DE2 FPGA with
program output observed through UART.

## Imported revision

This unified component contains the subsequently audited and repaired revision.
Before import, it passed:

- 12/12 directed branch checks
- 11/11 hazard-unit checks
- 29/29 architectural-program checks
- 17/17 focused pipeline-hazard checks
- Verilator lint with non-blocking warnings
- Yosys generic synthesis and structural checking

This totals 69/69 functional checks.

The corrected imported revision has not yet been reprogrammed onto the DE2.
The earlier physical demonstration and the later repaired RTL verification are
therefore documented separately.
