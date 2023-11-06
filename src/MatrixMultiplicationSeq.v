`timescale 1ns / 1ps

`ifndef _matrix_multiplication_seq
`define _matrix_multiplication_seq

`include "src/VectorMultiplicationSeq.v"

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
                                 output reg [(32 * L * N) - 1:0] result,
                                 output reg done);
    reg  [(32 * M) - 1:0] A_vector, B_vector;
    reg  input_changed = 1'b0;  // indicates that the input changed while in a computing cycle
    wire [31:0] res_scalar;
    wire vector_mult_done;

    // matrix B already transposed on input (we want tu multiply rows and columns -> subsequent parts of memory)
    // wire [(32 * N * M) - 1:0] B_T;

    // N * L VectorMultiplication modules from MatMulPar reduced to just 1
    // this computation is sequential (and takes some time)
    VectorMultiplicationSeq #(.VLEN(M)) vector_mult (
                                                .A(A_vector),
                                                .B(B_vector),
                                                .clk(clk),
                                                .result(res_scalar),
                                                .done(vector_mult_done)
                                                );

    integer cnt_a = 0, cnt_b = 0;

    // start computing the first output
    initial begin
        done = 1'b0;

        A_vector = A[(32 * M * cnt_a) +: 32 * M];
        B_vector = B_T[(32 * M * cnt_b) +: 32 * M];
    end

    // flip down switches
    always @ (A, B_T) begin
        done = 1'b0;
        input_changed = 1'b1;
    end

    // once output is complete, change the inputs for vector_mult
    always @(posedge vector_mult_done) begin
        // write the result from previous iteration (moved into next clock cycle to allow vector_mult computing time)
        result[(32 * N * cnt_a) + (32 * cnt_b) +: 32] = res_scalar;

        // start computing from the beginning
        if (input_changed) begin
            cnt_a = 0;
            cnt_b = 0;
            input_changed = 1'b0;
        end else begin
            // change counter variables
            if (cnt_b >= N - 1) begin  // move to next row
                cnt_b = 0;
                if (cnt_a >= L - 1)
                    done = 1'b1;  // cnt_a == L... calculation is done (we dont have to reset counter, it happens once input changes)
                else
                    cnt_a = cnt_a + 1;
            end else
                cnt_b = cnt_b + 1;
        end

        // change input data for VecMult (and let it compute for 1 clock cycle)
        A_vector = A[(32 * M * cnt_a) +: 32 * M];
        B_vector = B_T[(32 * M * cnt_b) +: 32 * M];
    end

endmodule;
`endif // _matrix_multiplication_seq