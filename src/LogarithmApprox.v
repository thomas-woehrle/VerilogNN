`include "src/FloatingAddition.v"
`include "src/FloatingMultiplication.v"
`include "src/FloatingDivision.v"

module LogarithmApprox(x_value,result);
input [31:0] x_value;
output [31:0] result;

wire [31:0] ln2 = 32'b0_01111110_01100010111001000011000;
wire [31:0] two = 32'b0_10000000_00000000000000000000000;
wire [31:0] eight = 32'b0_10000010_00000000000000000000000;
wire [31:0] hundrednintytwo = 32'b1_10000110_10000000000000000000000;//first bit flipped for -192  

wire [31:0] x_2, x_4;
wire [31:0] p2, p3, p4;
wire [31:0] sum1, sum2, sum3;

FloatingMultiplication mult2(.A(x_value),.B(x_value),.result(x_2));
FloatingMultiplication mult4(.A(x_2),.B(x_2),.result(x_4));

FloatingDivision Div2 (.A(x_value),.B(two),.result(p2));
FloatingDivision Div3 (.A(x_2),.B(eight),.result(p3));
FloatingDivision Div4 (.A(x_4),.B(hundrednintytwo),.result(p4));

FloatingAddition add1(.A(ln2),.B(p2),.result(sum1));
FloatingAddition add2(.A(sum1),.B(p3),.result(sum2));
FloatingAddition add3(.A(sum2),.B(p4),.result(sum3));

assign result = sum3;

endmodule
