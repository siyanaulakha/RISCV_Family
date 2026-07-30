TOP ?= RISC_V_IM

RTL := RISC_V_IM.v riscv_cpu.v controller.v datapath.v main_decoder.v alu_decoder.v alu.v reg_file.v instr_mem.v data_mem.v imm_extend.v adder.v mux2.v mux4.v reset_ff.v
BRANCH_RTL := controller.v main_decoder.v alu_decoder.v alu.v
BUILD := build

.PHONY: all check sim branch-test test lint synth clean

all: test lint synth

check:
	python3 scripts/check_repo.py

sim: check
	mkdir -p $(BUILD)
	iverilog -g2012 -Wall -s riscv_smoke_tb -o $(BUILD)/riscv_smoke.out tb/riscv_smoke_tb.v $(RTL)
	vvp $(BUILD)/riscv_smoke.out

branch-test: check
	mkdir -p $(BUILD)
	iverilog -g2012 -Wall -s branch_compare_tb -o $(BUILD)/branch_compare.out tb/branch_compare_tb.v $(BRANCH_RTL)
	vvp $(BUILD)/branch_compare.out

test: sim branch-test

lint: check
	verilator --lint-only --Wall --Wno-fatal --top-module $(TOP) $(RTL)

synth: check
	mkdir -p $(BUILD)
	yosys -q -l $(BUILD)/yosys.log -p 'read_verilog $(RTL); hierarchy -check -top $(TOP); proc; opt; check; stat'

clean:
	rm -rf $(BUILD) *.vcd *.fst
