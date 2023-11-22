`timescale 1ns/1ns
`include "Softmax.v"

module SoftmaxTB;
    reg [127:0] Vector;
    wire [127:0] result;

    Softmax S1(Vector,result);

    initial
    begin
        $dumpfile("vcd/SoftmaxTB.vcd");
        $dumpvars(0,SoftmaxTB);

        //01000000000000000000000000000000  2
        //01000000100000000000000000000000  4
        //01000001010100000000000000000000 13
        //01000001110010000000000000000000 25
        #20;
        // Vector = 128'b01000000000000000000000000000000_01000000100000000000000000000000_01000001010100000000000000000000_01000001110010000000000000000000;
        #20;
        Vector = 128'b11000000000000000000000000000000_01000000100000000000000000000000_01000001010100000000000000000000_01000001110010000000000000000000;
        #20;

        $display("%b",result);

        // 00111000100100001001011010011110 = 0.000068945097154937684535980224609375
        // 00111001110101010011110000010011 = 0.00040671284659765660762786865234375
        // 00111101001110001000110010111111 = 0.0450561009347438812255859375
        // 00111111011101000101100000001001 = 0.954468309879302978515625
    end

endmodule





//00111000100100001001011010011110001110011101010100111100000100110011110100111000100011001011111100111111011101000101100000001001