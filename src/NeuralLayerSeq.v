`timescale 1ns / 1ps

`ifndef _neural_layer_seq
`define _neural_layer_seq

`include "src/MatrixMultiplicationSeq.v"
`include "src/VectorAddition.v"
`include "src/ReLU.v"
`include "src/Sigmoid.v"
`include "src/Softmax.v"
`include "src/HyperbolicTangent.v"
`include "src/Softplus.v"

// Neural layer performing more sequential computations. Number of computing modules can be directly set by
// MOD_COUNT parameter, which is passed to the MatrixMultiplication module. Afterwards, one of the many activation
// functions is applied - this is determined in compile time.
//
// List of available activation functions (and their respective ACTIVATION values):
//   0 - ReLU
//   1 - sigmoid
//   2 - softmax (per-vector, not per-element)
//   3 - tanh (HyperbolicTangent)
//   4 - softplus
module NeuralLayerSeq #(parameter IN_SIZE = 1, OUT_SIZE = 1, MOD_COUNT = 1, ACTIVATION = 0)
                       (input  [(32 * IN_SIZE) - 1:0]            in,
                        input  [(32 * OUT_SIZE * IN_SIZE) - 1:0] weights,
                        input  [(32 * OUT_SIZE) - 1:0]           bias,
                        input                                    clk,
                        output [(32 * OUT_SIZE) - 1:0]           result,
                        output                                   done);  // only passed through from matmul, may not be 100 %

    wire [(32 * OUT_SIZE) - 1:0] res_matmul, res_bias;

    MatrixMultiplicationSeq #(  .L(OUT_SIZE),
                                .M(IN_SIZE),
                                .N(1),
                                .MOD_COUNT(MOD_COUNT)) matmul (
                                    .A(weights),
                                    .B_T(in),
                                    .clk(clk),
                                    .result(res_matmul),
                                    .done(done));
    VectorAddition #(.VLEN(OUT_SIZE)) add_bias(.A(res_matmul), .B(bias), .result(res_bias));

    // create modules for activation functions
    // Sigmoid and ReLU could be further sequentialized (into just 1 module)
    genvar i;
    generate
        case(ACTIVATION)
            0:
            for(i = 0; i < OUT_SIZE; i = i + 1)
                ReLU    relu   (.num(res_bias[32 * i +: 32]), .result(result[32 * i +: 32]));
            1:
            for(i = 0; i < OUT_SIZE; i = i + 1)
                Sigmoid sigmoid(.num(res_bias[32 * i +: 32]), .result(result[32 * i +: 32]));
            2:
            Softmax #(.VLEN(OUT_SIZE)) softmax(.in(res_bias), .result(result));

            3:
            for(i = 0; i < OUT_SIZE; i = i + 1)
                HyperbolicTangent htangent(.num(res_bias[32 * i +: 32]),.result(result[32 * i +: 32]));
            4:
            for(i = 0; i < OUT_SIZE; i = i + 1)
                Softplus softplus(.x_value(res_bias[32 * i +: 32]),.result(result[32 * i +: 32]));

        endcase
    endgenerate

endmodule;
`endif // _neural_layer_seq
