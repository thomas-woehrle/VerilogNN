# NN@FPGA

Series of projects implementing different Neural network architectures using Verilog. Intended use is for the Kria KV260 board.

## Module description

Various "groups" of modules are contained in the `src/` directory:
- Floating point operations on single numbers (`FloatingCompare.v`, `FloatingAddition.v`, ...)
- Operations on vectors of floating points (`VectorAddition.v`, ...)
- Operations on matrices of floating points (`MatrixMultiplication___.v`, ...)
- Mathematical functions, used as neural network activations (`E_Function.v`, `ReLO.v`, ...)
- Entire neural network layers

Various of these files, working with larger input data, are contained in multiple variants: `Par`, `Seq` and `Flex` (**WIP**).

The par implementation is the simplest one in principle, sort of a "brute-force" approach. It tries to construct all the computation modules at once,
so it would compute its output in one clock cycle (note that the clock is not attached). However, constructing multiple bigger modules would be wasteful
(or rather not realistic) on a real device. That is the purpose of the seq version, where we construct less computing modules, and we switch the in/out data
over clock cycles (just like a normal non-parallel CPU), making it slower, but taking less transistors.

Regarding the flex (**WIP**) version, it is essentially an improved version of seq, which enables us to "change the input size" in runtime (it is passed on a wire).
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

# Technical information

How to run this project, ...

## Recommended tools

Basic simulation of the Verilog code can be done using **Icarus Verilog** (`iverilog`) in a command line. The provided Makefile
serves just for this purpose - it automatically "compiles" provided testbenches into `vvp` files, which are then silently run in order
to produce `vcd` (Value Change Dump) waveform files. These files are then inspectable using **GTKWave** graphical utility.

Alternatively, this entire toolchain is replacable with **AMD Vivado**, needed for generating the bitstream that is uploaded to the real
FPGA board. However, for basic testing this might get unnecessarily complex, as Vivado can get painstakingly slow.

## Run bitsream on target

As the resulting modules need to interact with the memory shared between FPGA and CPU on the Kria board, the process of uploading and running modules
on Kria board is not so straightforward. It seems that when the identical bitstream is uploaded directly from Vivado ("Program Device" button),
this memory interaction on the board is not working. Following steps are taken from this [Xilinx example](https://xilinx.github.io/kria-apps-docs/creating_applications/2022.1/build/html/docs/vivado_accel_example.html#).
(As Xilinx has the tendency to remove older online resources, in case previous link doesn’t work, [try this](http://web.archive.org/web/20240117153005/https://xilinx.github.io/kria-apps-docs/creating_applications/2022.1/build/html/docs/vivado_accel_example.html))

### Prerequisites
- Vivado (design modelling, `.bit.bin` bitstream, `.xsa` design file)
- Vitis (package contains `XSCT` shell, needed for generating `.dtsi` HW description file, and Device Tree Compiler `dtc`)
- [Device Tree Generator (DTG)](https://github.com/Xilinx/device-tree-xlnx)
- `devmem` or `devmem2` [OSS implementation - Github](https://github.com/radii/devmem2)

### Generate bitstream (`.bit.bin`)
- Using Vivado, create a valid module and finish synthesis + implementation
- Settings -> Bitstream -> set `-bin_file` as True (only once)
- Generate bitstream... saved as `[project_path]/nn-fpga.runs/impl_1/[design_name]_wrapper.bin`
- Copy file to desired location, rename to `[app_name].bit.bin`

### Generate binary device tree (`.dtbo`)
- In Vivado (after bitstream is generated), File -> Export -> Export Hardware -> include bitstream
- `.xsa` file is generated... `[project_path]/nn-fpga.runs/impl_1/[design_name]_wrapper.xsa`
- Copy file to desired location, rename to `[app_name].xsa`
- using `xsct`, run the following commands:

```
hsi open_hw_design $DESIGN_NAME.xsa
hsi set_repo_path $HOME/device-tree-xlnx  # path to DTG
hsi create_sw_design device-tree -os device_tree -proc psu_cortexa53_0
hsi set_property CONFIG.dt_overlay true [hsi get_os]
hsi set_property CONFIG.dt_zocl true [hsi get_os]
hsi generate_target -dir temp
hsi close_hw_design [hsi current_hw_design]
exit
```

- Directory `temp` has been generated that contains `pl.dtsi`
- Convert `pl.dtsi` to `[app_name].dtbo`... `dtc -@ -O dtb -o [app_name].dtbo pl.dtsi`
- Copy file to desired location, `temp` directory can be removed now

This process is partially automized by `xsa2dtbo.sh` script, present on atcremers.

### Configuration file (`shell.json`)

```json
{
    "shell_type" : "XRT_FLAT",
    "num_slots" : "1"
}
```

### Upload, run

- Upload the `[app_name].bit.bin`, `[app_name].dtbo`. and `shell,json` files to Kria board using SSH (scp, rsync)
- Copy these files to newly created directory `/lib/firmware/xilinx/[app_name]`

App should now be ready to run. This means it should be visible when running `sudo xmutil listapps`. In order to run the app,
use `sudo xmutil unloadapp; sudo xmutil loadapp [app_name]`.

Now, the app should be running. Using the `devmem` (or `devmem2`) command, you should be able to access the memory of the program,
assuming you know which addresses the program maps to (this information is visible in Vivado). Running `sudo devmem2 0xa0000000`
should output the memory contents on address `0x a000 0000`. Default accessed memory size is 1 word (8 bytes). This command can be used
for writing to memory as well as reading from it.
