SOURCES = $(wildcard sim/*.v)
VVP_FILES = $(SOURCES:sim/%.v=run/%.vvp)

.PHONY: all
all: $(VVP_FILES)

.PHONY: clean
clean:
	rm run/* vcd/*

run/%.vvp: sim/%.v
	iverilog -o $@ $^
	vvp $@ >/dev/null
	mv *.vcd vcd