`timescale 1ns / 1ps

`ifndef _vector_multiplication_seq
`define _vector_multiplication_seq

`include "src/FloatingMultiplication.v"
`include "src/FloatingAddition.v"

// also known as dot product. Sequentialized into 1 multiplier and 1 adder.
// some compromise (adding number of submodules as a parameter) may be useful in the future.
module VectorMultiplicationSeq #(parameter VLEN = 1)
                                (input [(32 * VLEN) - 1:0] A,
                                 input [(32 * VLEN) - 1:0] B,
                                 input                     clk,
                                 output reg [31:0]         result,

                                 // indicates that computing is complete, output will not change anymore unless input changes
                                 output reg                done);
    reg  [31:0] A_item = 32'h0000_0000, B_item = 32'h0000_0000;
    wire [31:0] product, next_result;
    reg  input_changed = 1'b0;  // indicates that the input changed while in a computing cycle

    // computing modules
    FloatingMultiplication mult1(.A(A_item), .B(B_item), .result(product));  // element multiplication
    FloatingAddition add1(.A(product), .B(result), .result(next_result));  // sum the product with the output register

    initial begin
        result = 32'h0000_0000;  // eliminate unknown X's
        done = 1'b0;
    end

    // flip down switches
    always @ (A, B) begin
        done = 1'b0;
        input_changed = 1'b1;
    end

    // computing cycle (essentially a for cycle simulated by clock)
    // stop computing once done is set to 1 (otherwise, sum would grow infinitely)
    integer i = 0;
    always @ (posedge (clk & ~done)) begin
        // add what was calculated in the previous cycle
        // as long as A_item, B_item and result are the same, next_result wire doesnt change
        result = next_result;

        // start computing from the beginning
        if (input_changed) begin
            i = 0;
            result = 32'h0000_0000;
            input_changed = 1'b0;
        end

        // computing finished
        if (i >= VLEN)
            done = 1'b1;
        else begin
            // load data into input registers
            A_item = A[32 * i +: 32];
            B_item = B[32 * i +: 32];

            // computation is performed until the next clock tick (and added to result afterwards)

            // increase counter
            i = i + 1;
        end
    end
endmodule;
`endif // _vector_multiplication_seq