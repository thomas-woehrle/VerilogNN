`timescale 1ns / 1ps

`ifndef _neural_layer_seq
`define _neural_layer_seq

`include "src/MatrixMultiplicationSeq.v"
`include "src/VectorAddition.v"
`include "src/ReLU.v"
`include "src/Sigmoid.v"

module NeuralLayerSeq #(parameter IN_SIZE = 1, OUT_SIZE = 1)
                       (input  [(32 * IN_SIZE) - 1:0]            in,
                        input  [(32 * OUT_SIZE * IN_SIZE) - 1:0] weights,
                        input  [(32 * OUT_SIZE) - 1:0]           bias,
                        input                                    activation,  // 0 for ReLU, 1 for sigmoid
                        input                                    clk,
                        output [(32 * OUT_SIZE) - 1:0]           result);

    wire [(32 * OUT_SIZE) - 1:0] res_matmul, res_bias, res_relu, res_sigmoid;

    MatrixMultiplicationSeq #(.L(OUT_SIZE), .M(IN_SIZE), .N(1)) matmul(.A(weights), .B(in), .clk(clk), .result(res_matmul));
    VectorAddition #(.VLEN(OUT_SIZE)) add_bias(.A(res_matmul), .B(bias), .result(res_bias));

    // create modules for activation functions
    // this could be further sequentialized to 1 Sigmoid and 1 ReLU module
    genvar i;
    generate
        for(i = 0; i < OUT_SIZE; i = i + 1) begin
            ReLU    relu   (.num(res_bias[32 * i +: 32]), .result(res_relu[32 * i +: 32]));
            Sigmoid sigmoid(.num(res_bias[32 * i +: 32]), .result(res_sigmoid[32 * i +: 32]));
        end
    endgenerate

    // determine output
    assign result = (activation == 1'b0) ? res_relu : res_sigmoid;
endmodule;
`endif // _neural_layer_seq