SOURCES = $(wildcard sim/*.v)
VVP_FILES = $(SOURCES:sim/%.v=run/%.vvp)

.PHONY: all
all: $(VVP_FILES)

.PHONY: clean
clean:
	rm run/* vcd/*

# @ echo "The pattern target is \"$@\""
# @ echo "The FIRST prerequisite is \"$<\""
# @ echo "All prerequisites are \"$^\""
# @ echo "The stem (what replaces % in pattern) is \"$*\""
run/%.vvp: sim/%.v run vcd
# -o... output file name
# -s... starting point (module name)
# -I... where to search for includes (everything from src/ directory)
	iverilog -o $@ $< -s $* -I src/
	vvp $@ -lxt2 >/dev/null

# run/NeuralNetwork1TB.vvp: sim/NeuralNetwork1TB.v
# 	@ echo "Ingoring $<, takes too long"

run:
	mkdir run

vcd:
	mkdir vcd
