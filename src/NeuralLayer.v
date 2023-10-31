`timescale 1ns / 1ps

`ifndef _neural_layer
`define _neural_layer

`include "src/MatrixMultiplication.v"
`include "src/ReLU.v"
`include "src/Sigmoid.v"


module NeuralLayer #(parameter IN_SIZE = 1, OUT_SIZE = 1)
                    (input  [(32 * IN_SIZE) - 1:0]            in,
                     input  [(32 * OUT_SIZE * IN_SIZE) - 1:0] weights,
                     input                                    activation,  // 0 for ReLU, 1 for sigmoid
                     output [(32 * OUT_SIZE) - 1:0]           out);

    output [(32 * OUT_SIZE) - 1:0] out_pretransform, out_relu, out_sigmoid;

    MatrixMultiplication #(.L(OUT_SIZE), .M(IN_SIZE), .N(1)) matmul(.A(weights), .B(in), .result(out_pretransform));

    // create modules for activation functions
    genvar i;
    generate
        for(i = 0; i < OUT_SIZE; i = i + 1) begin
            ReLU relu(.num(out_pretransform[32 * i +: 32]), .result(out_relu[32 * i +: 32]));
            Sigmoid sigmoid(.num(out_pretransform[32 * i +: 32]), .result(out_sigmoid[32 * i +: 32]));
        end
    endgenerate

    // determine output
    assign out = (activation == 1'b0) ? out_relu : out_sigmoid;
endmodule;
`endif // _neural_layer