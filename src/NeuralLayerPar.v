`timescale 1ns / 1ps

`ifndef _neural_layer_par
`define _neural_layer_par

`include "src/MatrixMultiplicationPar.v"
`include "src/VectorAddition.v"
`include "src/ReLU.v"
`include "src/Sigmoid.v"
`include "src/Softmax.v"
`include "src/HyperbolicTangent.v"
`include "src/Softplus.v"

//                                                           0 - ReLU, 1 - sigmoid, 2 - softmax
module NeuralLayerPar #(parameter IN_SIZE = 1, OUT_SIZE = 1, ACTIVATION = 0)
                       (input  [(32 * IN_SIZE) - 1:0]            in,
                        input  [(32 * OUT_SIZE * IN_SIZE) - 1:0] weights,
                        input  [(32 * OUT_SIZE) - 1:0]           bias,
                        output [(32 * OUT_SIZE) - 1:0]           result);

    wire [(32 * OUT_SIZE) - 1:0] res_matmul, res_bias;

    MatrixMultiplicationPar #(.L(OUT_SIZE), .M(IN_SIZE), .N(1)) matmul(.A(weights), .B(in), .result(res_matmul));
    VectorAddition #(.VLEN(OUT_SIZE)) add_bias(.A(res_matmul), .B(bias), .result(res_bias));

    // create modules for activation functions
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
`endif // _neural_layer_par
