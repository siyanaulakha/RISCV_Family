.PHONY: all test lint synth clean \
        baseline baseline-test baseline-lint baseline-synth \
        pipeline pipeline-test pipeline-lint pipeline-synth

all: baseline pipeline

test: baseline-test pipeline-test

lint: baseline-lint pipeline-lint

synth: baseline-synth pipeline-synth

baseline:
	$(MAKE) -C components/rv32i_baseline all

baseline-test:
	$(MAKE) -C components/rv32i_baseline test

baseline-lint:
	$(MAKE) -C components/rv32i_baseline lint

baseline-synth:
	$(MAKE) -C components/rv32i_baseline synth

pipeline:
	$(MAKE) -C components/rv32i_pipeline all

pipeline-test:
	$(MAKE) -C components/rv32i_pipeline test

pipeline-lint:
	$(MAKE) -C components/rv32i_pipeline lint

pipeline-synth:
	$(MAKE) -C components/rv32i_pipeline synth

clean:
	-$(MAKE) -C components/rv32i_baseline clean
	-$(MAKE) -C components/rv32i_pipeline clean
