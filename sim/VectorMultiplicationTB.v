`timescale 1ns / 1ps
`include "src/VectorMultiplication.v"
`include "src/DisplayFloat.v"

module VectorMultiplicationTB #(parameter VLEN = 5);  // 5-element float vectors
    // this syntax would not pass to the module, easier to do it as one big vector
    // reg [31:0] A, B [0:VLEN-1];

    reg [(32 * VLEN) - 1:0] A, B;
    wire [31:0] result;
    real value;  // real (64bit FP) not synthesizable, only for sim comparison

    // pack the A, B arrays (not necessary in current implementation)
    // genvar i;
    // for(i = 0; i < VLEN; i = i + 1) begin
    //     assign A_packed[32 * i +: 31] = A[i];
    //     assign B_packed[32 * i +: 31] = B[i];
    // end

    VectorMultiplication #(.VLEN(VLEN)) mult (.A(A), .B(B), .result(result));

    DisplayFloat display_result (.num(result), .id("Res"), .format(1'b1));

    // numbers assignments
    initial
    begin
        #1
        A[0   +: 32] = 32'b0_10000000_10011001100110011001100;  // 3.2
        B[0   +: 32] = 32'b0_10000001_00001100110011001100110;  // 4.2

        A[32  +: 32] = 32'b0_01111110_01010001111010111000010;  // 0.66
        B[32  +: 32] = 32'b0_01111110_00000101000111101011100;  // 0.51

        A[64  +: 32] = 32'b1_01111110_00000000000000000000000;  // -0.5
        B[64  +: 32] = 32'b1_10000001_10011001100110011001100;  // -6.4

        A[96  +: 32] = 32'b1_01111110_00000000000000000000000;  // -0.5
        B[96  +: 32] = 32'b0_10000001_10011001100110011001100;  //  6.4

        A[128 +: 32] = 32'h4034b4b5;  //  2.82
        B[128 +: 32] = 32'hbf70f0f1;  // -0.94
    end

    // displaying
    initial
    begin
        // dump to vcd file for GTKWave
        $dumpfile("vcd/VectorMultiplicationTB.vcd");
        $dumpvars;

        #100
        $display("Expected Value: %f", (3.2 * 4.2) + (0.66 * 0.51) + ((-0.5) * (-6.4)) + ((-0.5) * (6.4)) + (2.82*(-0.94)));

        $finish;
    end

endmodule
