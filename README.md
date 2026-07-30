# RISCV Family

Unified RTL repository for:

- Modular single-cycle RV32I reference core
- Five-stage pipelined RV32I processor
- UART/MMIO platform
- Integrated pipelined RV32I UART SoC

## Current verification

- Single-cycle RV32I: smoke, branch regression, Verilator and Yosys passed
- Five-stage pipelined RV32I: 69/69 functional checks passed
- UART/MMIO platform: 31/31 functional checks passed
- Original pipelined processor demonstrated on a Terasic DE2 FPGA through UART

The cleaned pipelined revision has passed portable simulation, lint and generic
synthesis. Re-running that corrected revision on the DE2 and capturing updated
Quartus reports remains planned.
