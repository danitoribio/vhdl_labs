# Makefile for compiling and running main_tb

# Define variables
VHDL_FILES := filter_parallel.vhd main.vhd main_tb.vhd rom.vhd sine_generator.vhd sine_generator_tb.vhd
TB_ENTITY := main_tb
GHDL_CMD := ghdl
GTKWAVE_CMD := gtkwave
GHDL_FLAGS := --std=08
GHDL_WORK := work
WAVE_FILE := wave.ghw
GHDL_RUN_FLAGS := --wave=$(WAVE_FILE)
SIM_TIME := --stop-time=6754us

# Target: all (default target)
all: compile run

# Target: compile (compile the testbench)
compile: $(VHDL_FILES)
	$(GHDL_CMD) -a $(GHDL_FLAGS) $^

# Target: run (run the simulation)
run:
	$(GHDL_CMD) -e $(GHDL_FLAGS) $(TB_ENTITY)
	$(GHDL_CMD) -r $(GHDL_FLAGS) $(TB_ENTITY) $(GHDL_RUN_FLAGS) $(SIM_TIME)

# Target: clean (remove compiled files and waves)
clean:
	rm -f *.o *.cf $(TB_ENTITY) $(GHDL_WORK)/*
	rm -f wave.ghw

.PHONY: all compile run clean
