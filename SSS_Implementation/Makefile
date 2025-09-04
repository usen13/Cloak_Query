# Simplified Makefile without src/ benchmark/ include/ lib/ directories
# Builds test binaries directly from files in test/

BDIR=bin
TDIR=test

CC=g++
CXXFLAGS= -pthread -g
INCLUDES= -I/usr/include/gtest -I/usr/include/openssl \
          -I ./path_oram_Cloak_Query/include \
          -I ./cpp-sql-server/src
# Link libraries
LDLIBS= -lgtest -lgtest_main -pthread -lsodium -lssl -lcrypto
# Common flags
override CPPFLAGS += --std=c++17 -Wall -Wno-unknown-pragmas -fPIC

# Test binaries
TESTSSSQL = $(BDIR)/test-sss-sql
TESTSUM   = $(BDIR)/test-sum
TESTAVG   = $(BDIR)/test-avg
TESTMAX   = $(BDIR)/test-max
TESTMIN   = $(BDIR)/test-min

ENTRYPOINTCC = $(CC) -o $@ $^ $(CPPFLAGS) $(CXXFLAGS) $(INCLUDES) $(LDLIBS)

all: $(TESTSSSQL) $(TESTSUM) $(TESTAVG) $(TESTMAX) $(TESTMIN)

# Ensure bin directory exists
$(BDIR):
	mkdir -p $(BDIR)

# Build rules for tests (no OBJ prerequisites)
$(TESTSSSQL): $(TDIR)/test-sss-sql.cpp | $(BDIR)
	$(ENTRYPOINTCC)

$(TESTSUM): $(TDIR)/test-sum.cpp | $(BDIR)
	$(ENTRYPOINTCC)

$(TESTAVG): $(TDIR)/test-avg.cpp | $(BDIR)
	$(ENTRYPOINTCC)

$(TESTMAX): $(TDIR)/test-max.cpp | $(BDIR)
	$(ENTRYPOINTCC)

$(TESTMIN): $(TDIR)/test-min.cpp | $(BDIR)
	$(ENTRYPOINTCC)

# Run targets
run-test-sss-sql: $(TESTSSSQL)
	$(TESTSSSQL)

run-test-sum: $(TESTSUM)
	$(TESTSUM)

run-test-avg: $(TESTAVG)
	$(TESTAVG)

run-test-max: $(TESTMAX)
	$(TESTMAX)

run-test-min: $(TESTMIN)
	$(TESTMIN)

# Cleaning
clean:
	rm -rf $(BDIR)/*
	rm -rf	Query_Result_SSS

.PHONY: all clean \
	run-test-sss-sql run-test-sum run-test-avg run-test-max run-test-min
