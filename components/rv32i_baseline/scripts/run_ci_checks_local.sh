#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."
mkdir -p results/ci
{
  echo "commit=$(git rev-parse HEAD 2>/dev/null || echo unknown)"
  echo "runner=$(uname -a)"
  echo "iverilog=$(iverilog -V 2>&1 | head -n 1)"
  echo "yosys=$(yosys -V 2>&1 | head -n 1)"
  echo "python=$(python3 --version)"
} | tee results/ci/tool-versions.txt
set -o pipefail
python3 scripts/check_repo.py 2>&1 | tee results/ci/structural-audit.log
make sim 2>&1 | tee results/ci/iverilog-simulation.log
make synth 2>&1 | tee results/ci/yosys-synthesis-console.log
cp -f build/yosys.log results/ci/yosys.log
