// https://github.com/akilm/FPU-IEEE-754

`timescale 1ns / 1ps

`ifndef _floating_multiplication
`define _floating_multiplication

module FloatingMultiplication (
    input  [31:0] A,
    input  [31:0] B,
    output [31:0] result
);

  wire [23:0] A_Mantissa = {1'b1, A[22:0]}, B_Mantissa = {1'b1, B[22:0]};
  wire [7:0] A_Exponent = A[30:23], B_Exponent = B[30:23];
  wire A_sign = A[31], B_sign = B[31];

  reg [47:0] Temp_Mantissa;  // raw result of the mantissa multiplication
  wire [22:0] Mantissa = Temp_Mantissa[45:23];  // highest bits of Temp_Mantissa, except for 1 carry bit (which causes bitshift)
  reg [8:0] Exponent;  // one bit bigger because of potential overflow
  reg Sign;

  assign result = {Sign, Exponent[7:0], Mantissa};

  always @(*) begin
    Sign = A_sign ^ B_sign;

    Exponent = (A_Exponent + B_Exponent < 'd127) ? 8'd0 : A_Exponent + B_Exponent - 'd127;  // prevent exponent underflow
    Temp_Mantissa = A_Mantissa * B_Mantissa;  // multiply mantissas

    // "carry"... increase exponent, shift
    if (Temp_Mantissa[47]) begin
      Temp_Mantissa = Temp_Mantissa << 1;  // Mantissa = Temp_Mantissa[46:24]
      Exponent = Exponent + 1;
    end

    // prevent exponent overflow
    if (Exponent[8]) Exponent[7:0] = 8'hff;
  end
endmodule
`endif  // _floating_multiplication
