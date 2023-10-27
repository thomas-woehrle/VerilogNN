`timescale 1ns / 1ps

// not synthesizable, only for testbench purposes
// converts custom float into `real` type and displays it whenever the number changes
module DisplayFloat (input [31:0] num,
                     input [3*8:1] id,
                     input format);

    real value;

    always @ (num, format) begin
        //           exponent (biased)     mantissa converted to real (and shifted)        number sign
        value =(2 ** (num[30:23] - 127)) * ($itor({1'b1, num[22:0]}) / 2 ** 23) * ((-1) ** (num[31]));
        if (format)
            $display("[DisplayFloat] %s: %f", id, value);
        else
            $display("[DisplayFloat] %s: %b 1.%b * 2 ^ (%0d - 127)", num[31], num[22:0], num[30:23]);
    end
endmodule