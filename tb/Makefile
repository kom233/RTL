SIM ?= verilator

TOPLEVEL_LANG = verilog
TOPLEVEL = IntMul

VERILOG_SOURCES = $(PWD)/../core/mul.sv

COMPILE_ARGS += -I$(PWD)/..
COMPILE_ARGS += -Wno-DECLFILENAME

# Verilator waveform tracing
EXTRA_ARGS += --trace
EXTRA_ARGS += --trace-fst
EXTRA_ARGS += --trace-structs

COCOTB_TEST_MODULES = test_mul

include $(shell cocotb-config --makefiles)/Makefile.sim