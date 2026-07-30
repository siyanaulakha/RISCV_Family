.PHONY: all test lint synth clean \
        baseline baseline-test baseline-lint baseline-synth

all: baseline

test: baseline-test

lint: baseline-lint

synth: baseline-synth

baseline:
	$(MAKE) -C components/rv32i_baseline all

baseline-test:
	$(MAKE) -C components/rv32i_baseline test

baseline-lint:
	$(MAKE) -C components/rv32i_baseline lint

baseline-synth:
	$(MAKE) -C components/rv32i_baseline synth

clean:
	$(MAKE) -C components/rv32i_baseline clean
