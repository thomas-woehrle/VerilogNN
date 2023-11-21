`timescale 1ns / 1ps

// Outputs a vector of floating point numbers in designated format. One element of output changes on each
// clock cycle (takes some time to initialize). In order to create multiple modules giving different values, use the
// START parameter from [0, 10].
module TestVectorFloats #(parameter START = 0, VLEN = 1)
                        (input clk,
                        output reg [(32 * VLEN) - 1:0] vec);
    reg [31:0] num;
    integer idx = START, vec_tracker = 0;

    always @ (posedge clk) begin
        case (idx)
            0:  num = 32'b0_10000000_10011001100110011001100;  //  3.2
            1:  num = 32'b0_10000001_00001100110011001100110;  //  4.2
            2:  num = 32'b0_01111110_01010001111010111000010;  //  0.66
            3:  num = 32'b0_01111110_00000101000111101011100;  //  0.51
            4:  num = 32'b1_01111110_00000000000000000000000;  // -0.5
            5:  num = 32'b1_10000001_10011001100110011001100;  // -6.4
            6:  num = 32'b0_01111100_00000000000000000000000;  //  0.125
            7:  num = 32'b0_10000011_10011001100110011001100;  // 25.6
            8:  num = 32'b1_01111011_10011001100110011001100;  // -0.1
            9:  num = 32'b0_00000000_00000000000000000000000;  //  0.0
            10: num = 32'b0_11111111_00000000000000000000000;  //  inf
            default: num = 32'h0000_0000;  // also 0.0, shouldn't occur as long as START param is valid
        endcase

        vec[32 * vec_tracker +: 32] = num;
        idx = (idx < 10) ? idx + 1 : 0;
        vec_tracker = (vec_tracker < VLEN - 1) ? vec_tracker + 1 : 0;
    end

endmodule