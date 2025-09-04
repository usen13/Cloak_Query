#!/usr/bin/env bash
set -euo pipefail

TOP_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ORAM_DIR="$TOP_DIR/path_oram_Cloak_Query"

command -v gdb >/dev/null 2>&1 || { echo "gdb not found. Install with: sudo apt-get update && sudo apt-get install -y gdb"; exit 1; }

mkdir -p "$ORAM_DIR/gdb-logs"

pushd "$ORAM_DIR" >/dev/null

for i in 1 2 3 4 5 6; do
  echo "[build] make debug-test-ser$i"
  make -j "debug-test-ser$i"

  BIN="$ORAM_DIR/bin/test-ser$i"
  if [[ ! -x "$BIN" ]]; then
    echo "Missing executable: $BIN"
    exit 1
  fi

  echo "[gdb] Running $BIN"
  gdb -q --batch \
      -ex "set pagination off" \
      -ex "run" \
      -ex "bt" \
      -ex "quit 0" \
      --args "$BIN" "$@" | tee "$ORAM_DIR/gdb-logs/ser${i}.log"
done

# Run aggregation query tests after server tests complete
echo "[aggregate] Running aggregation tests..."
make run-test-sum
make run-test-avg
make run-test-max
make run-test-min

popd >/dev/null

echo "Done. GDB logs saved in $ORAM_DIR/gdb-logs/"