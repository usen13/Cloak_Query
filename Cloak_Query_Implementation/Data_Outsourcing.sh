#!/usr/bin/env bash
set -euo pipefail

TOP_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Input file (defaults to lineitem_10MB.tbl) can be changed to any file in Shamir_Parser/ or current directory
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

# Clean pre-existing binaries/outputs
echo "[0/3] Cleaning previous builds and generated files..."
make -C "$TOP_DIR/cpp-sql-server" clean || true
make -C "$TOP_DIR/path_oram_Cloak_Query" clean || true
make -C "$TOP_DIR/Shamir_Parser" clean || true

# Create secret-shared and encrypted data
echo "[1/3] Building Shamir_Parser..."
pushd "$TOP_DIR/Shamir_Parser" >/dev/null
make -j
echo "[2/3] Encrypting: $INPUT_PATH"
./shamir_parser encrypt "$INPUT_PATH"
popd >/dev/null

# Translate Queries
echo "[3/3] Building cpp-sql-server..."
pushd "$TOP_DIR/cpp-sql-server" >/dev/null
make -j sql_handler_test
popd >/dev/null

echo "Done."