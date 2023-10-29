`timescale 1ns / 1ps
`include "src/FloatingMultiplication.v"
`include "src/FloatingAddition.v"

// Uses Newton Raphson Iterations to find the reciprocal of the Divisor and then Multiplies the Reciprocal with the Dividend.
module FloatingDivision(input [31:0]A,
                         input [31:0]B,
                         input clk,
                         output overflow,
                         output underflow,
                         output exception,
                         output [31:0] result);

    wire [7:0] Exponent;
    wire [31:0] temp1, temp2, temp3, temp4, temp5, temp6, temp7, debug;
    wire [31:0] reciprocal;
    wire [31:0] x0, x1, x2, x3;
    reg [6:0] exp_adjust;
    reg [31:0] B_scaled;
    reg en1, en2, en3, en4, en5;
    reg dummy;
    // ----Initial value----       B_Mantissa * 2 ^ -1              cca 1.88
    FloatingMultiplication M1(.A({{1'b0, 8'd126, B[22:0]}}), .B(32'h3ff0f0f1), .clk(clk), .result(temp1));
    //                         cca 2.82      -abs(temp1)
    FloatingAddition A1(.A(32'h4034b4b5), .B({1'b1, temp1[30:0]}), .result(x0));

    /*----First Iteration----*/
    FloatingMultiplication M2(.A({{1'b0, 8'd126, B[22:0]}}), .B(x0), .clk(clk), .result(temp2));
    FloatingAddition A2(.A(32'h40000000), .B({!temp2[31], temp2[30:0]}), .result(temp3));
    FloatingMultiplication M3(.A(x0), .B(temp3), .clk(clk), .result(x1));

    /*----Second Iteration----*/
    FloatingMultiplication M4(.A({1'b0, 8'd126, B[22:0]}), .B(x1), .clk(clk), .result(temp4));
    FloatingAddition A3(.A(32'h40000000), .B({!temp4[31], temp4[30:0]}), .result(temp5));
    FloatingMultiplication M5(.A(x1), .B(temp5), .clk(clk), .result(x2));

    /*----Third Iteration----*/
    FloatingMultiplication M6(.A({1'b0, 8'd126, B[22:0]}), .B(x2), .clk(clk), .result(temp6));
    FloatingAddition A4(.A(32'h40000000), .B({!temp6[31], temp6[30:0]}), .result(temp7));
    FloatingMultiplication M7(.A(x2), .B(temp7), .clk(clk), .result(x3));

    /*----Reciprocal : 1/B----*/
    assign Exponent = x3[30:23]+8'd126-B[30:23];
    assign reciprocal = {B[31], Exponent, x3[22:0]};

    /*----Multiplication A*1/B----*/
    FloatingMultiplication M8(.A(A), .B(reciprocal), .clk(clk), .result(result));
endmodule
