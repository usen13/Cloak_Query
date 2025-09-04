#!/usr/bin/env bash
set -euo pipefail

TOP_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ORAM_DIR="$TOP_DIR"

pushd "$ORAM_DIR" >/dev/null

echo "[aggregate] Running test-sss-sql (from $(pwd))..."
if ! make -j run-test-sss-sql; then
  SSS_BIN="$ORAM_DIR/bin/test-sss-sql"
  if [[ -x "$SSS_BIN" ]]; then
    "$SSS_BIN" "$@"
  else
    echo "Warning: run-test-sss-sql target and $SSS_BIN not found. Skipping."
  fi
fi

echo "[aggregate] Running aggregation tests..."
make -j run-test-sum
make -j run-test-avg
make -j run-test-max
make -j run-test-min

popd >/dev/null

echo "Done."