# Cloak_Query: Build, Data Outsourcing, and Query Processing

This repository contains two runnable setups:
- Cloak_Query_Implementation (Path ORAM based)
- SSS_Implementation (Shamir Secret Sharing based)

Both setups provide two Bash scripts each:
- Data_Outsourcing.sh — builds and encrypts the input table to generate secret shares.
- Query_Processing.sh — builds and runs server/query tests (including aggregation queries).

## Prerequisites
Install the following packages (Ubuntu/Debian example):

```bash
sudo apt-get update
sudo apt-get install -y build-essential cmake gdb \
  libsodium-dev libssl-dev \
  libgtest-dev
```

Notes:
- GoogleTest headers are expected in `/usr/include/gtest` and libraries available to the linker (`-lgtest -lgtest_main`).
- If you see linker errors for gtest, install `libgmock-dev` as well.

## Data Outsourcing (generate shares)

### Path ORAM implementation
Script: `Cloak_Query_Implementation/Data_Outsourcing.sh`

What it does:
- Builds `Shamir_Parser`.
- Runs `./shamir_parser encrypt <input>` to generate server share files.
- Builds `cpp-sql-server` target(s).

Usage:
```bash
chmod +x Cloak_Query_Implementation/Data_Outsourcing.sh
# Default input is Shamir_Parser/lineitem_10MB.tbl
Cloak_Query_Implementation/Data_Outsourcing.sh
# Or provide a custom input path (absolute or relative)
Cloak_Query_Implementation/Data_Outsourcing.sh /path/to/your/table.tbl
```

Outputs:
- Shares dir: `Cloak_Query_Implementation/shares/` (files like `server_1.txt`, ...)
- Optional metrics dir: `Cloak_Query_Implementation/metrics/`

### SSS implementation
Script: `SSS_Implementation/Data_Outsourcing.sh`

This script mirrors the steps above within `SSS_Implementation/`.

Usage:
```bash
chmod +x SSS_Implementation/Data_Outsourcing.sh
# Default input is Shamir_Parser/lineitem_10MB.tbl under SSS_Implementation
SSS_Implementation/Data_Outsourcing.sh
# Or provide a custom input path
SSS_Implementation/Data_Outsourcing.sh /path/to/your/table.tbl
```

Outputs:
- Shares dir: `SSS_Implementation/shares/` (if generated here). The SSS tests can also read shares from `Cloak_Query_Implementation/shares/`.

## Query Processing (run tests and aggregation queries)

### Path ORAM implementation
Script: `Cloak_Query_Implementation/Query_Processing.sh`

What it does:
- Builds and runs `bin/test-ser1..6` under gdb (non-interactive). GDB logs are saved.
- Runs aggregation tests: `run-test-sum`, `run-test-avg`, `run-test-max`, `run-test-min`.

Usage:
```bash
chmod +x Cloak_Query_Implementation/Query_Processing.sh
# Optional: pass GTest args (e.g., filters) and they will be forwarded to tests
Cloak_Query_Implementation/Query_Processing.sh --gtest_filter=YourSuite.*
```

Outputs:
- GDB logs: `Cloak_Query_Implementation/path_oram_Cloak_Query/gdb-logs/ser{1..6}.log`
- Query results: `Cloak_Query_Implementation/Query_Result/...`
  - For AVG, results are written into the per-query folder (e.g., `../Query_Result/AVGOR/avg_results.txt`) and a combined file (`../Query_Result/avg_results.txt`) if enabled in tests.

### SSS implementation
Script: `SSS_Implementation/Query_Processing.sh`

What it does:
- Exports `SHARES_DIR` so tests can find the generated shares.
  - Prefers `SSS_Implementation/shares/` if present, otherwise falls back to `Cloak_Query_Implementation/shares/`.
- Runs `run-test-sss-sql` (or executes the binary directly if the make target isn’t present).
- Runs aggregation tests: `run-test-sum`, `run-test-avg`, `run-test-max`, `run-test-min` (using `SSS_Implementation/Makefile`).

Usage:
```bash
chmod +x SSS_Implementation/Query_Processing.sh
SSS_Implementation/Query_Processing.sh
# You can override the shares location explicitly
SHARES_DIR=/absolute/path/to/Cloak_Query_Implementation/shares SSS_Implementation/Query_Processing.sh
```

## Troubleshooting

- No rule to make target 'obj/…':
  - Ensure you are using the simplified `SSS_Implementation/Makefile` that builds directly from `test/*.cpp`.
- Shares not found (e.g., "Error opening file: server_1.txt"):
  - Verify the shares exist in one of:
    - `Cloak_Query_Implementation/shares/`
    - `SSS_Implementation/shares/`
  - If needed, set `SHARES_DIR` to the correct absolute path.
- GDB exits after the first server:
  - The Path ORAM script uses `-ex "quit 0"` to ensure the loop continues across all servers.

## Repo layout (key paths)
- `Cloak_Query_Implementation/Shamir_Parser/` — Shamir encoder and Makefile
- `Cloak_Query_Implementation/path_oram_Cloak_Query/` — ORAM library and tests (including aggregation tests)
- `Cloak_Query_Implementation/cpp-sql-server/` — helper SQL handler
- `Cloak_Query_Implementation/shares/` — generated shares
- `SSS_Implementation/test/` — SSS tests (`test-sss-sql.cpp`, aggregation tests)
- `SSS_Implementation/bin/` — built test binaries (SSS)

## Quick start
1) Generate shares (choose one):
```bash
Cloak_Query_Implementation/Data_Outsourcing.sh
# or
SSS_Implementation/Data_Outsourcing.sh
```

2) Run query processing:
```bash
Cloak_Query_Implementation/Query_Processing.sh
# and/or
SSS_Implementation/Query_Processing.sh
```
