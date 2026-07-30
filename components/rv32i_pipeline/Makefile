TOP ?= riscv_im_f
BUILD ?= build

RTL := \
	sources_1/new/t1c_riscv_cpu.v \
	sources_1/new/riscv_cpu.v \
	sources_1/new/controller.v \
	sources_1/new/main_decoder.v \
	sources_1/new/alu_decoder.v \
	sources_1/new/datapath.v \
	sources_1/new/branch_compare.v \
	sources_1/new/HAZARD_UNIT.v \
	sources_1/new/IF_PL_REG.v \
	sources_1/new/DE_PL_REG.v \
	sources_1/new/MW_PL_REG.v \
	sources_1/new/WB_PL_REG.v \
	sources_1/new/alu.v \
	sources_1/new/reg_file.v \
	sources_1/new/instr_mem.v \
	sources_1/new/data_mem.v \
	sources_1/new/imm_extend.v \
	sources_1/new/adder.v \
	sources_1/new/mux2.v \
	sources_1/new/mux3.v \
	sources_1/new/mux4.v \
	sources_1/new/reset_ff.v

BRANCH_RTL := \
	sources_1/new/alu.v \
	sources_1/new/alu_decoder.v \
	sources_1/new/branch_compare.v

HAZARD_RTL := sources_1/new/HAZARD_UNIT.v

.PHONY: all check generate test branch-test hazard-unit-test program-test \
	hazard-program-test lint synth clean

all: test lint synth

generate:
	python3 scripts/gen_test_programs.py

check: generate
	python3 scripts/check_repo.py

branch-test: check
	mkdir -p $(BUILD)
	iverilog -g2012 -Wall -s branch_compare_tb \
		-o $(BUILD)/branch_compare.out tb/branch_compare_tb.v $(BRANCH_RTL)
	vvp $(BUILD)/branch_compare.out

hazard-unit-test: check
	mkdir -p $(BUILD)
	iverilog -g2012 -Wall -s hazard_unit_tb \
		-o $(BUILD)/hazard_unit.out tb/hazard_unit_tb.v $(HAZARD_RTL)
	vvp $(BUILD)/hazard_unit.out

program-test: check
	mkdir -p $(BUILD)
	iverilog -g2012 -Wall -s pipeline_program_tb \
		-o $(BUILD)/pipeline_program.out tb/pipeline_program_tb.v $(RTL)
	vvp $(BUILD)/pipeline_program.out

hazard-program-test: check
	mkdir -p $(BUILD)
	iverilog -g2012 -Wall -s pipeline_hazard_program_tb \
		-o $(BUILD)/pipeline_hazard_program.out tb/pipeline_hazard_program_tb.v $(RTL)
	vvp $(BUILD)/pipeline_hazard_program.out

test: branch-test hazard-unit-test program-test hazard-program-test

lint: check
	verilator --lint-only --Wall --Wno-fatal --top-module $(TOP) $(RTL)

synth: check
	mkdir -p $(BUILD)
	yosys -q -l $(BUILD)/yosys.log -p \
		'read_verilog $(RTL); hierarchy -check -top $(TOP); proc; opt; check; stat'

clean:
	rm -rf $(BUILD) *.vcd *.fst results.txt
