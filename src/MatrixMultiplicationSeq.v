`timescale 1ns / 1ps

`ifndef _matrix_multiplication_seq
`define _matrix_multiplication_seq

`include "src/VectorMultiplicationPar.v"

// Multiplies two matrices of dimensions L * M and M * N. As input can be only a vector, it is automatically
// assumed that the matrix is passed in row-major order. Output matrix will have dimensions L * N and will be
// in row-major order as well. Optimized for cases when simulator/FPGA cannot handle the so many modules
// at once and performs some calculations at the clock cycle. For NN usage, M (inputs) > L (outputs) > N = 1 is expected.
//
// Note that matrix B must be transposed on input (can be ignored if it has only 1 row or column).
module MatrixMultiplicationSeq #(parameter L = 1, M = 1, N = 1)
                                (input      [(32 * L * M) - 1:0] A,
                                 input      [(32 * N * M) - 1:0] B_T,  // Transposed !!!
                                 input                           clk,
                                 output reg [(32 * L * N) - 1:0] result);
    reg  [(32 * M) - 1:0] A_vector, B_vector;
    wire [31:0] res_scalar;

    // matrix B already transposed on input (we want tu multiply rows and columns -> subsequent parts of memory)
    // wire [(32 * N * M) - 1:0] B_T;

    // N * L VectorMultiplication modules from MatMulPar reduced to just 1
    // problematically, for NN usage M is the biggest number - less cycles but more computing
    VectorMultiplicationPar #(.VLEN(M)) vector_mult (
                                                .A(A_vector),
                                                .B(B_vector),
                                                .result(res_scalar)
                                                );

    integer cnt_a = 0, cnt_b = 0;
    always @(posedge clk) begin
        // write the result from previous iteration (moved into next clock cycle to allow VecMult computing time)
        result[(32 * N * cnt_a) + (32 * cnt_b) +: 32] = res_scalar;

        // change counter variables
        if (cnt_b >= N - 1) begin  // move to next row
            cnt_b = 0;
            cnt_a = (cnt_a >= L - 1) ? 0 : cnt_a + 1;  // cnt_a == L... wrap around to the beginning
        end else
            cnt_b = cnt_b + 1;

        // change input data for VecMult (and let it compute for 1 clock cycle)
        A_vector = A[(32 * M * cnt_a) +: 32 * M];
        B_vector = B_T[(32 * M * cnt_b) +: 32 * M];
    end

endmodule;
`endif // _matrix_multiplication_seq