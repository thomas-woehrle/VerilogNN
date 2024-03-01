# VerilogNN

Multiple Verilog modules to work with floating points, used when creating a neural network. Created with FPGA develompment in mind.
This repo is part of a bigger project [NN@FPGA](https://github.com/ruzicka02/NN.FPGA).

## Module description

Various "groups" of modules are contained in the `src/` directory:
- Floating point operations on single numbers (`FloatingCompare.v`, `FloatingAddition.v`, ...)
- Operations on vectors of floating points (`VectorAddition.v`, ...)
- Operations on matrices of floating points (`MatrixMultiplication___.v`, ...)
- Mathematical functions, used as neural network activations (`E_Function.v`, `ReLO.v`, ...)
- Entire neural network layers

Various of these files, working with larger input data, are contained in multiple variants: `Par`, `Seq` and `Flex`.

The par implementation is the simplest one in principle, sort of a "brute-force" approach. It tries to construct all the computation modules at once,
so it would compute its output in one clock cycle (note that the clock is not attached). However, constructing multiple bigger modules would be wasteful
(or rather not realistic) on a real device. That is the purpose of the seq version, where we construct less computing modules, and we switch the in/out data
over clock cycles (just like a normal non-parallel CPU), making it slower, but taking less transistors.

Regarding the flex version, it is essentially an improved version of seq, which enables us to "change the input size" in runtime (it is passed on a wire).
We have the real input size (buffer size), which is set to accommodate the biggest input possible, but we can say that the input is actually smaller
(and the remaining wires are unused). This causes the computation to finish faster than if you would just fill it with zeros (it calculates only with
the real values). This is needed if you have for example one matrix multiplying module, but you want to switch the matrix sizes (such as different NN layers).

## Directory structure

Following directories contain source files in Verilog:

- `src/`... Source files, mostly intended as synthesizable modules.
- `sim/`... Testbench files runnable using Icarus Verilog. These are mostly ignored when working with Vivado (replaced by their `bd` designs).
- `sim_vivado/`... Additional utility modules.

To extract data from program, bigger data sources (such as Neural Network weights) are stored in the `data/` directory.

In addition, following directories are created when running the `make` command:

- `run/`... Simulation files created by `iverilog` from simulation testbenches. These files are runnable by `vvp` simulator (part of iverilog package).
- `vcd/`... VCD waveform files, openable for example in GTKWave. Constructed whenever the files in `run/` are launched.

Keep in mind that the Makefile does not contain any information about dependencies between the source files. This problem is especially notable when a module in `src/` is changed and we wish to compile its unmodified testbench in `sim/`. Although this solution is not ideal, a quick workaround can be achieved with the following command:

```
make --always-make [target]
```

## Recommended tools

Basic simulation of the Verilog code can be done using **Icarus Verilog** (`iverilog`) in a command line. The provided Makefile
serves just for this purpose - it automatically "compiles" provided testbenches into `vvp` files, which are then silently run in order
to produce `vcd` (Value Change Dump) waveform files. These files are then inspectable using **GTKWave** graphical utility.

When using these modules for real HW deployment on an FPGA, **AMD Vivado** is essentially unavoidable for generating the bitstream that is uploaded to the real FPGA board. However, for basic testing this might get unnecessarily complex, as Vivado can get painstakingly slow.

For more information on how to use these tools, see the documentation within the [main repository](https://github.com/ruzicka02/NN.FPGA).
