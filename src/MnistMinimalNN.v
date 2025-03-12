// not really functional like this
module MnistMinimalNN #(
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
    input clk,
    output [(32 * OutWidth) - 1:0] out,
    output done
);
  wire [(32 * L1Width) - 1:0] l1_out;
  wire [(32 * L2Width) - 1:0] l2_out;
  wire l1_done, l2_done, out_done;

  NeuralLayerSeq #(
      .IN_SIZE(InWidth),
      .OUT_SIZE(L1Width),
      .ACTIVATION(0)
  ) layer_1 (
      .data(in),
      .weights(l1_weights),
      .bias(l1_biases),
      .clk(clk),
      .result(l1_out),
      .done(l1_done)
  );

  NeuralLayerSeq #(
      .IN_SIZE(L1Width),
      .OUT_SIZE(L2Width),
      .ACTIVATION(0)
  ) layer_2 (
      .data(l1_out),
      .weights(l2_weights),
      .bias(l2_biases),
      .clk(clk),
      .result(l2_out),
      .done(l2_done)
  );

  // Activation 2 => Softmax
  NeuralLayerSeq #(
      .IN_SIZE(L2Width),
      .OUT_SIZE(OutWidth),
      .ACTIVATION(0)
  ) layer_out (
      .data(l2_out),
      .weights(out_weights),
      .bias(out_biases),
      .clk(clk),
      .result(out),
      .done(out_done)
  );

  // could done just be out_done?
  assign done = l1_done && l2_done && out_done;

endmodule
