`timescale 1ns / 1ps
`include "src/MatrixMultiplicationPar.v"
`include "src/MatrixMultiplicationSeq.v"
`include "src/DisplayFloat.v"

module MatrixMultiplicationTB #(parameter L = 2, M = 2, N = 2);  // 2x2 float matrices
    reg clk = 0;
    always begin
       clk = ~clk;
       #1;
    end

    reg  [(32 * L * M) - 1:0] A;
    reg  [(32 * M * N) - 1:0] B;
    wire [(32 * N * M) - 1:0] B_T;
    wire [(32 * L * N) - 1:0] result_par, result_seq;
    real value[1:0][1:0];

    assign B_T[0  +: 32] = B[0  +: 32];
    assign B_T[64 +: 32] = B[32 +: 32];
    assign B_T[32 +: 32] = B[64 +: 32];
    assign B_T[96 +: 32] = B[96 +: 32];

    MatrixMultiplicationPar #(.L(L), .M(M), .N(N)) mult_par (.A(A), .B(B), .result(result_par));
    MatrixMultiplicationSeq #(.L(L), .M(M), .N(N)) mult_seq (.A(A), .B_T(B_T), .clk(clk), .result(result_seq));

    DisplayFloat display_result1 (.num(result_par[0  +: 32]), .id("0_0"), .format(1'b1));
    DisplayFloat display_result2 (.num(result_par[32 +: 32]), .id("0_1"), .format(1'b1));
    DisplayFloat display_result3 (.num(result_par[64 +: 32]), .id("1_0"), .format(1'b1));
    DisplayFloat display_result4 (.num(result_par[96 +: 32]), .id("1_1"), .format(1'b1));

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
    end

    // displaying
    initial
    begin
        // dump to vcd file for GTKWave
        $dumpfile("vcd/MatrixMultiplicationTB.vcd");
        $dumpvars;

        #100
        if (result_par !== result_seq)
            $display("Results of matrix multiplications differ! Par vs. Seq:\n%h\n%h", result_par, result_seq);
        else
            $display("Results of matrix multiplications are the same");

        $display("Expected Values: \n(%f %f)\n(%f %f)",
            (3.2    *   4.2)  + (0.66   * (-6.4)),
            (3.2    * (0.51)) + (0.66   * ( 6.4)),
            ((-0.5) *   4.2)  + ((-0.5) * (-6.4)),
            ((-0.5) * (0.51)) + ((-0.5) * ( 6.4)));

        $finish;
    end

endmodule
