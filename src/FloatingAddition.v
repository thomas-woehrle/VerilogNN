// https://github.com/akilm/FPU-IEEE-754

`timescale 1ns / 1ps

`ifndef _floating_addition
`define _floating_addition

`include "src/FloatingCompare.v"

module FloatingAddition (input [31:0]A,
                         input [31:0]B,
                         output reg [31:0] result);
    reg [23:0] A_Mantissa, B_Mantissa, result_Mantissa;  // real mantissa is 23b, this is {1'b1, mantissa} = 24b long
    wire MSB;
    reg [7:0] A_Exponent, B_Exponent, result_Exponent, diff_Exponent;
    reg A_sign, B_sign;
    reg [32:0] Temp;
    reg carry;
    reg [2:0] one_hot;
    wire comp;

    integer i;

    // compare absolute values of A, B
    FloatingCompare comp_abs(.A({1'b0, A[30:0]}), .B({1'b0, B[30:0]}), .result(comp));

    always @(*) begin
        // let A >= B (switch numbers if needed)
        A_Mantissa = comp ? {1'b1,A[22:0]} : {1'b1,B[22:0]};
        A_Exponent = comp ? A[30:23] : B[30:23];
        A_sign = comp ? A[31] : B[31];

        B_Mantissa = comp ? {1'b1,B[22:0]} : {1'b1,A[22:0]};
        B_Exponent = comp ? B[30:23] : A[30:23];
        B_sign = comp ? B[31] : A[31];

        diff_Exponent = A_Exponent - B_Exponent;  // >= 0
        B_Mantissa = (B_Mantissa >> diff_Exponent);  // shift B to same exponent

        // sum the mantissas (and store potential carry)
        //  1b              24b    1 if signs are the same     24b          24b
        {carry, result_Mantissa} = (A_sign ~^ B_sign) ? A_Mantissa + B_Mantissa : A_Mantissa - B_Mantissa;
        result_Exponent = A_Exponent;

        // adjust mantissa to format 1.xxxx (bit 23 is 1)
        if(carry) begin
            result_Mantissa = result_Mantissa >> 1;
            result_Exponent = result_Exponent + 1;
        end
        else if(|result_Mantissa != 1'b1) begin  // mantissa contains no 1 or unknown value (result should be 0, while loop below would get stuck)
            result_Exponent = 0;  // 2 ** (0-127) is almost 0
        end
        else begin
            i = 0;  // fixed limit of iterations because Vivado saw this as an infinite loop
            while(result_Mantissa[23] !== 1'b1 && result_Exponent > 0 && i < 24) begin  // 1st bit is not 1, but there is some 1 in the mantissa
                result_Mantissa = result_Mantissa << 1;
                result_Exponent = result_Exponent - 1;
                i = i + 1;
            end
        end

        result = {A_sign, result_Exponent, result_Mantissa[22:0]};
    end
endmodule
`endif // _floating_addition