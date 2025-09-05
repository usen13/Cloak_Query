# Cloak_Query: Data Outsourcing, and Query Processing
This repository contains the implementation for Cloak_Query, an approach to ensure obfuscation as well as integrity during query execution. This repository contains two runnable setups:
- Cloak_Query_Implementation (Path ORAM based)
- SSS_Implementation (Shamir Secret Sharing based)

Both setups provide two Bash scripts each:
- Data_Outsourcing.sh — builds and encrypts the input table to generate secret shares.
- Query_Processing.sh — builds and runs server/query tests (including aggregation queries).

**WARNING: You must run Data_Outsourcing.sh before running Query_Processing.sh (for both implementations).**
If you do not run Data_Outsourcing.sh first, the implementation will not work and will cause errors (e.g., missing shares/backups, file-not-found failures).

## Run with Docker (recommended for a clean toolchain)

This repo includes a dev container recipe (Dockerfile.dev) that installs all build/test dependencies (g++, cmake, gtest/gmock, libsodium, OpenSSL, Boost, nlohmann-json, Python + sqlparse, gdb). It is recommend all code is executed inside the container to avoid missing dependencies.

Build the image:
```bash
docker build -f Dockerfile.dev -t |your docker image name| .
# If you changed Dockerfile.dev, force rebuild:
# docker build --no-cache -f Dockerfile.dev -t |your docker image name| .
```

Once built launch your container and run the scripts as usual:
```bash
# Generate shares (Path ORAM)
chmod +x Cloak_Query_Implementation/Data_Outsourcing.sh
Cloak_Query_Implementation/Data_Outsourcing.sh  

# Run ORAM servers + aggregation tests
chmod +x Cloak_Query_Implementation/Query_Processing.sh
Cloak_Query_Implementation/Query_Processing.sh  

# SSS variant
chmod +x SSS_Implementation/Data_Outsourcing.sh
SSS_Implementation/Data_Outsourcing.sh

chmod +x SSS_Implementation/Query_Processing.sh
SSS_Implementation/Query_Processing.sh
```

Note: **Run Data_Outsourcing.sh first**. Skipping it will result in errors during Query_Processing.sh because required shares/backup files won’t exist.

Details on individual implementations follow below:
## Data Outsourcing (generate shares)

### Path ORAM implementation
Script: `Cloak_Query_Implementation/Data_Outsourcing.sh`

What it does:
- Builds `Shamir_Parser`.
- Runs `./shamir_parser encrypt <input>` to generate server share files.
- Builds `cpp-sql-server` which will be used to translate SQL queries.
- If the user wishes to clean existing build outputs they do so by invoking `make clean` in the above folders. 

Outputs:
- Shares dir: `Cloak_Query_Implementation/shares/` (files like `server_1.txt`, ...)
- Optional metrics dir: `Cloak_Query_Implementation/metrics/` which mentions the total time it took to create the shares.

### SSS implementation
Script: `SSS_Implementation/Data_Outsourcing.sh`

This script mirrors the steps above within `SSS_Implementation/`.

Usage:
```bash
chmod +x SSS_Implementation/Data_Outsourcing.sh
# Default input is Shamir_Parser/lineitem_10MB.tbl under SSS_Implementation
SSS_Implementation/Data_Outsourcing.sh
```

Outputs:
- Shares dir: `SSS_Implementation/shares/` (if generated here).

## Query Processing (run tests and aggregation queries)

### Path ORAM implementation
Script: `Cloak_Query_Implementation/Query_Processing.sh`

What it does:
- Builds and runs `bin/test-ser1..6` under gdb (non-interactive).
- Creates backups for each ORAM that are created under backup `backup_ser1..6`
- Runs aggregation tests: `run-test-sum`, `run-test-avg`, `run-test-max`, `run-test-min`.
- Saves timings metrics for the above steps in the backups folder `backup_ser1..6`.
- Saves query results in the Query_Results folder.
- If the user wishes to clean existing build outputs please invokde `make clean` in the `path_oram_Cloak_Query` folder. 

Usage:
```bash
chmod +x Cloak_Query_Implementation/Query_Processing.sh
# Optional: pass GTest args (e.g., filters) and they will be forwarded to tests
Cloak_Query_Implementation/Query_Processing.sh --gtest_filter=YourSuite.*
```

Outputs:
- Query results: `Cloak_Query_Implementation/Query_Result/...`
  - For AVG, results are written into the per-query folder (e.g., `../Query_Result/AVGOR/avg_results.txt`) and a combined file (`../Query_Result/avg_results.txt`) if enabled in tests. The same is true for all other aggregation queries.

### SSS implementation
Script: `SSS_Implementation/Query_Processing.sh`

What it does:
- Exports `SHARES_DIR` so tests can find the generated shares.
  - Prefers `SSS_Implementation/shares/` if present, otherwise creates new shares.
- Runs `run-test-sss-sql` (or executes the binary directly if the make target isn’t present).
- Runs aggregation tests: `run-test-sum`, `run-test-avg`, `run-test-max`, `run-test-min` (using `SSS_Implementation/Makefile`).

Usage:
```bash
chmod +x SSS_Implementation/Query_Processing.sh
SSS_Implementation/Query_Processing.sh
```
## Experiment Timing Metrics:
Cloak_Query timing metrics can be found in the following paths:
- For Shamir secret shares creation `Cloak_Query_Implementation/metrics`.
- For Path ORAM related metrics (such as shuffling, MAC verification path retrieval) the metrics are located in the corresponding backup folder `backup_ser1..6`.
SSS implementation timing metrics can be found in the following paths:
- Query results as well as timing metrics for each query can be found in `SSS_Implementation/Query_Result_SSS` .

## Troubleshooting
- For Docker:
- Editing files: edit on the host (mounted into the container). If you prefer in-container editing: `apt-get update && apt-get install -y nano` (or `vim`).
- Python sqlparse errors:
  - The image installs sqlparse for Python 3 (`pip3 install sqlparse`). If tests call `python` instead of `python3`, either use `python3` or install `python-is-python3` in the image.
  - Verify: `python3 -c "import sqlparse; print(sqlparse.__version__)"`.
- GoogleTest/GoogleMock: Dockerfile.dev builds and installs the static libs from `/usr/src/googletest`. If you use a different base image, ensure `libgtest-dev libgmock-dev` are installed and built.
- Git “dubious ownership” inside the container:
  - Prefer running the container with `--user "$(id -u)":"$(id -g)"` (as shown).
  - Or allow this path: `git config --global --add safe.directory /workspace/cloak_query`.
- Permission denied when deleting outputs:
  - Happens if files were created as root. Fix: `chown -R "$(id -u)":"(id -g)" <dir>` or always run the container with `--user "$(id -u)":"$(id -g)"`.
- Rebuild the image after changing Dockerfile.dev:
  - Use `--no-cache` to avoid stale layers.

Other issues:
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
- `Cloak_Query_Implementation/cpp-sql-server/` — helper SQL handler and query translator
- `Cloak_Query_Implementation/shares/` — generated shares
- `SSS_Implementation/test/` — SSS tests (`test-sss-sql.cpp`, aggregation tests)
- `SSS_Implementation/bin/` — built test binaries (SSS)
- `SSS_Implementation/shares/` — generated shares (SSS)
- `SSS_Implementation/cpp-sql-server/` — simialr SQL handler and query translator to the Cloak_Query implementation (SSS)

## Quick start in Docker container
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
