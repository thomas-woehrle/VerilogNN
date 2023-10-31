`timescale 1ns / 1ps

`ifndef _matrix_multiplication
`define _matrix_multiplication

`include "src/VectorMultiplication.v"

// Multiplies two matrices of dimensions L * M and M * N. As input can be only a vector, it is automatically
// assumed that the matrix is passed in row-major order. Output matrix will have dimensions L * N and will be
// in row-major order as well.
module MatrixMultiplication #(parameter L = 1, M = 1, N = 1)
                             (input  [(32 * L * M) - 1:0] A,
                              input  [(32 * M * N) - 1:0] B,
                              output [(32 * L * N) - 1:0] result);

    // transpose matrix B (we want tu multiply rows and columns -> subsequent parts of memory)
    wire [(32 * N * M) - 1:0] B_T;

    for(i = 0; i < N; i = i + 1)  // row index in B_T
        for(j = 0; j < M; j = j + 1)  // column index in B_T (element in row)
            //       32 * M = row size in B_T;            32 * N = row size in B
            assign B_T[(32 * M * i) + (32 * j) +: 32] = B[(32 * N * j) + (32 * i) +: 32];

    genvar i, j;
    generate
        for(i = 0; i < L; i = i + 1)  // row index in result (selects in matrix A)
            for(j = 0; j < N; j = j + 1)  // col index in result (selects in matrix B_T)
                VectorMultiplication #(.VLEN(M)) vector_mult (
                                                    .A(A[(32 * M * i) +: 32 * M]),
                                                    .B(B_T[(32 * M * j) +: 32 * M]),
                                                    .result(result[(32 * N * i) + (32 * j) +: 32])
                                                    );
    endgenerate
endmodule;
`endif // _matrix_multiplication