# Verification Plan

| ID | Area | Test | Status |
|---|---|---|---|
| V-01 | Integration | reset, clock, and known PC progression | PASS |
| V-02 | Branch | BEQ equal and unequal operands | PASS |
| V-03 | Branch | BNE equal and unequal operands | PASS |
| V-04 | Branch | BLT/BGE signed corner cases | PASS |
| V-05 | Branch | BLTU/BGEU unsigned corner cases | PASS |
| V-06 | ALU | all implemented ALU operations | TODO |
| V-07 | Register file | writes, reads, and immutable `x0` | TODO |
| V-08 | Loads | byte, halfword, word and extension behavior | TODO |
| V-09 | Stores | byte, halfword, word and alignment behavior | TODO |
| V-10 | Control flow | JAL and JALR targets and link values | TODO |
| V-11 | Program | architectural signature comparison | TODO |
| V-12 | FPGA | Quartus timing and utilization reports | TODO |

## Current branch regression

The directed branch regression contains 12 self-checking cases covering:

- all six RV32I branch encodings;
- equality and inequality;
- signed minimum and maximum values;
- signed subtraction-overflow-sensitive comparisons;
- unsigned zero versus `0xffffffff`;
- unsigned `0xffffffff` versus zero.

## Claim boundary

The repository is not currently claimed to be formally RISC-V compliant. Formal or architectural-compliance claims require a supported architectural-test environment and complete target integration.
