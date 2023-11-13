`timescale 1ns/1ns
`include "src/HyperbolicTangent.v"


module HyperbolicTangentTB;
    reg [31:0] Vector;
    wire [31:0] result;

    HyperbolicTangent H1(Vector,result);

    initial 
    begin
        $dumpfile("HyperbolicTangentTB.vcd");
        $dumpvars(0,HyperbolicTangentTB);

        #20;
        Vector = 32'b11000000000000000000000000000000;//-2
        #20;
        Vector = 32'b01000000000000000000000000000000;// 2
        #20;
        Vector = 32'b01000000100000000000000000000000;// 4
        #20;
        Vector = 32'b01000000100000000000000000000000;// 13
        #20;
        Vector = 32'b01000001110010000000000000000000;// 25
        #20;
        $display("%b",result);
    end
endmodule
