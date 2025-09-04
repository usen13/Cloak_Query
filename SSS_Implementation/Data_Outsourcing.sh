#!/usr/bin/env bash
set -euo pipefail

TOP_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Input file (defaults to lineitem_10MB.tbl)
INPUT_FILE="${1:-lineitem_10MB.tbl}"

# Resolve input file to an absolute path
if [[ -f "$INPUT_FILE" ]]; then
  INPUT_PATH="$(cd "$(dirname "$INPUT_FILE")" && pwd)/$(basename "$INPUT_FILE")"
elif [[ -f "$TOP_DIR/Shamir_Parser/$INPUT_FILE" ]]; then
  INPUT_PATH="$TOP_DIR/Shamir_Parser/$INPUT_FILE"
elif [[ -f "$TOP_DIR/$INPUT_FILE" ]]; then
  INPUT_PATH="$TOP_DIR/$INPUT_FILE"
else
  echo "Error: input file not found: $INPUT_FILE"
  echo "Usage: $0 [input_file]"
  exit 1
fi

echo "[1/3] Building Shamir_Parser..."
pushd "$TOP_DIR/Shamir_Parser" >/dev/null
make -j
echo "[2/3] Encrypting: $INPUT_PATH"
./shamir_parser encrypt "$INPUT_PATH"
popd >/dev/null

echo "[3/3] Building cpp-sql-server..."
pushd "$TOP_DIR/cpp-sql-server" >/dev/null
make -j sql_handler_test
popd >/dev/null

echo "Done."