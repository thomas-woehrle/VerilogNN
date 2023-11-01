`timescale 1ns / 1ps

`ifndef _vector_addition
`define _vector_addition

`include "src/FloatingAddition.v"

module VectorAddition #(parameter VLEN = 1)
                       (input  [(32 * VLEN) - 1:0] A,
                        input  [(32 * VLEN) - 1:0] B,
                        output [(32 * VLEN) - 1:0] result);

    genvar i;
    generate
        for(i = 0; i < VLEN; i = i + 1) begin
            wire [31:0] A_item = A[32 * i +: 32];
            wire [31:0] B_item = B[32 * i +: 32];

            FloatingAddition add1(.A(A_item), .B(B_item), .result(result[32 * i +: 32]));  // element-wise addition
        end
    endgenerate
endmodule;
`endif // _vector_addition