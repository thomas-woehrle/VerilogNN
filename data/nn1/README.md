## NN format

- Input layer... 28x28 (=784) image from MNIST dataset
- 1st hidden layer... 15 neurons, sigmoid activation
- output layer... 10 neurons, softmax activation to predict probability

## Data description

All files use "ASCII binary" (ASCII symbols of '0' (0x30) and '1' (0x31)), making them very bulky (compression would save a lot of space). This format is read
by Verilog testbench using `$readmemb`.

- `bias[n].mem`... vector of biases in n-th layer, contains `OUT_SIZE` numbers for respective layer
- `weights[n].mem`... matrix (row-major) of weights in n-th layer, contains `IN_SIZE x OUT_SIZE` numbers for respective layer
- `input[n].mem`... sample input, containing 784 floats. True label is added at the end (0 - 9), usually causing a warning in the Verilog simulator for not reading
  the entire file

There were some inconsistencies and changes regarding whether layers are indexed from 0 or 1, so if stuff isn't working, check that.