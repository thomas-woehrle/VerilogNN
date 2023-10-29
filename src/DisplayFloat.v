`timescale 1ns / 1ps

// not synthesizable, only for testbench purposes
// converts custom float into `real` type and displays it whenever the number changes
module DisplayFloat (input [31:0] num,
                     input [3*8:1] id,
                     input format);

    real value;

    always @ (num, format) begin
        //      mantissa converted to real (and shifted)        number sign
        value = ($itor({1'b1, num[22:0]}) / 2 ** 23) * ((-1) ** (num[31]));
        if (num[30:23] >= 127)  // (biased) exponent >= 0
            //              this part is effectively int, so it should not be in <0, 1> range
            value = value * (2 ** (num[30:23] - 127));
        else
            value = value / (2 ** (127 - num[30:23]));

        if (format)  // == 1'b1
            $display("[DisplayFloat] %s: %f", id, value);
        else
            $display("[DisplayFloat] %s: %b 1.%b * 2 ^ (%0d - 127) = %f", id, num[31], num[22:0], num[30:23], value);
    end
endmodule