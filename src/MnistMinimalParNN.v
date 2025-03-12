// not functional cause too big because parallel and not sequential
module MnistMinimalParNN #(
    localparam integer InWidth  = 784,
    localparam integer L1Width  = 128,
    localparam integer L2Width  = 64,
    localparam integer OutWidth = 10
) (
    input [(32 * InWidth) - 1:0] in,
    input [(32 * L1Width * InWidth) - 1:0] l1_weights,
    input [(32 * L1Width) - 1:0] l1_biases,
    input [(32 * L2Width * L1Width) -1:0] l2_weights,
    input [(32 * L2Width) - 1:0] l2_biases,
    input [(32 * OutWidth * L2Width) - 1:0] out_weights,
    input [(32 * OutWidth) - 1:0] out_biases,
    output [(32 * OutWidth) - 1:0] out
);
  wire [(32 * L1Width) - 1:0] l1_out;
  wire [(32 * L2Width) - 1:0] l2_out;

  NeuralLayerPar #(
      .IN_SIZE(InWidth),
      .OUT_SIZE(L1Width),
      .ACTIVATION(0)
  ) layer_1 (
      .in(in),
      .weights(l1_weights),
      .bias(l1_biases),
      .result(l1_out)
  );

  NeuralLayerPar #(
      .IN_SIZE(L1Width),
      .OUT_SIZE(L2Width),
      .ACTIVATION(0)
  ) layer_2 (
      .in(l1_out),
      .weights(l2_weights),
      .bias(l2_biases),
      .result(l2_out)
  );

  // Activation 2 => Softmax
  NeuralLayerPar #(
      .IN_SIZE(L2Width),
      .OUT_SIZE(OutWidth),
      .ACTIVATION(0)
  ) layer_out (
      .in(l2_out),
      .weights(out_weights),
      .bias(out_biases),
      .result(out)
  );

endmodule
