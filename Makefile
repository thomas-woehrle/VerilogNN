SOURCES = $(wildcard sim/*.v)
VVP_FILES = $(SOURCES:sim/%.v=run/%.vvp)

.PHONY: all
all: $(VVP_FILES)

.PHONY: clean
clean:
	rm run/* vcd/*

run/%.vvp: sim/%.v run vcd
	iverilog -o $@ $<
	vvp $@ >/dev/null

run:
	mkdir run

vcd:
	mkdir vcd
