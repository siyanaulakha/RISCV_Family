# Five-Stage Pipelined RV32I Verification

Date: 2026-07-30

## Portable RTL verification

| Check | Result |
|---|---:|
| Directed branch comparison | 12/12 PASS |
| Hazard-unit regression | 11/11 PASS |
| Architectural program | 29/29 PASS |
| Focused pipeline-hazard program | 17/17 PASS |
| Total functional checks | 69/69 PASS |
| Structural audit | PASS |
| Verilator lint | PASS with non-blocking warnings |
| Yosys generic synthesis and structural check | PASS |

## Verified behavior

The regression exercises:

- signed and unsigned branch comparisons;
- execute- and memory-stage forwarding;
- forwarding priority;
- load-use stalls;
- false-dependency avoidance for immediate instructions;
- branch and jump flushing;
- store-data forwarding;
- load-result dependencies;
- JAL and JALR behavior;
- register and memory architectural outcomes.

## Hardware demonstration boundary

The original collaborative pipelined implementation was demonstrated on a
Terasic DE2 FPGA with program output observed through UART.

The repaired revision recorded here has passed portable simulation, lint and
generic synthesis. It has not yet been reprogrammed onto the DE2, so the
original physical demonstration and the repaired-revision verification are
documented separately.

## Non-blocking warnings

Verilator reports a historical top-level filename/module-name mismatch and
some intentionally unused instruction and local-memory address bits. These do
not prevent elaboration or synthesis.
