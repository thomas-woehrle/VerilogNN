`timescale 1ns/1ns
`include "src/E_Function.v"

module E_FunctionTB;

    reg [31:0] X_val;
    wire [31:0] result;


    e_function E1(X_val,result);

    initial
    begin

        $dumpfile("E_FunctionTB.vcd");
        $dumpvars(0,E_FunctionTB);

        #20;
        X_val = 32'b0_01111111_00000000000000000000000;//1
        #20;
        X_val = 32'b0_10000000_00000000000000000000000;//2
        #20;
        X_val = 32'b11000000000000000000000000000000; // -2
        #20;
    end

endmodule
