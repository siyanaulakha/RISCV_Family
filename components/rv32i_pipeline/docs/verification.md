# Verification Plan

The cleanup candidate separates four self-checking regressions:

1. **Branch comparison (12 checks):** BEQ/BNE and signed/unsigned relational corner cases, including subtraction-overflow-sensitive operands.
2. **Hazard unit (11 checks):** EX/MEM and MEM/WB forwarding, priority, x0 suppression, true and false load-use dependencies, and redirect flushing.
3. **Architectural program:** executes the original 79-word RV32I program and checks 26 registers plus byte, halfword, and word memory results.
4. **Focused hazard program:** exercises ALU forwarding, forwarded store data, a load-use interlock, branch/JAL/JALR flushing, LUI/AUIPC dependencies, and JALR bit-zero clearing.

`make lint` performs a Verilator lint pass. `make synth` performs a generic Yosys hierarchy, process, optimization, and consistency check.

The repository does not yet include RISC-V compliance tests, formal proofs, privilege modes, CSRs, interrupts, or the M extension.
