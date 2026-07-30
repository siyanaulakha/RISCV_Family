# Verification Results

## Current verified results

| Check | Result |
|---|---|
| Structural repository audit | PASS |
| Integrated smoke simulation | PASS |
| Final smoke-test PC | `0x0000004c` |
| Directed branch regression | 12/12 PASS |
| Yosys RTL synthesis/check | PASS |
| Verilator lint | No errors |
| Formal architectural compliance | Not performed |
| FPGA timing/utilization | Not yet recorded |

## Tools

- Icarus Verilog 14.0 development build
- Yosys 0.67+102
- Verilator 5.051 development build
- OSS CAD Suite

## Expected warnings

Verilator may report intentionally unused address or instruction bits because:

- instruction and data memories are bounded;
- instruction addresses are word-aligned;
- opcode fields are divided between controller and datapath modules.

Icarus may report full-array sensitivity for the asynchronous data-memory read model.

Generated logs are intentionally excluded from Git. CI and local runs regenerate them as needed.
