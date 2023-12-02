`timescale 1ns / 1ps

module VectorAdditionFlex #(parameter LBUF = 128)
                            (input [(32*LBUF)-1:0] A,
                             input [(32*LBUF)-1:0] B,
                             input                 clk,
                             input [31:0]          l,
                             output reg [(32*LBUF)-1:0] result,
                             output reg done);

    reg  [32 * LBUF - 1:0] A_storage, B_storage;
    reg  input_changed = 1'b0;
    wire [32 * LBUF - 1:0] res_sum;

    integer count = 0;
 
    initial begin
        done = 1'b0;
        A_storage <= A[0 +: 32 ];
        B_storage <= B[0 +: 32 ];  
    end

    always @(input_changed) begin
        done = 1'b0;
        A_storage <= A[0 +: 32 ];  
        B_storage <= B[0 +: 32 ]; 
        count = 0;
    end

    always @ (A, B, l) begin
        done <= 1'b0;
        input_changed <= 1'b1;
    end

    FloatingAddition F1(.A(A_storage),.B(B_storage),.result(res_sum));

    always @(posedge clk) begin
        result[32 * count +: 32] = res_sum;

        if (input_changed) begin
            count = 0;
            input_changed = 1'b0;
        end else begin
            if(count >= l-1) begin 
                done = 1'b1;
            end else begin
                count = count + 1;
            end
        end
        
        A_storage = A[32 * count +: 32 ];  
        B_storage = B[32 * count +: 32 ];
    end

endmodule












                                


