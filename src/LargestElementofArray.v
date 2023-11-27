`timescale 1ns / 1ns

module LargestElementofArray #(parameter ELEMENT_SIZE = 32, ELEMENT_COUNT = 10)
                              (input     [(32* ELEMENT_COUNT) -1 : 0]    in,
                               input                                     clk,
                               output    [31:0]                          result);

    wire [ELEMENT_SIZE-1:0] largestelement [ELEMENT_COUNT];
    
    genvar i;
    generate
        for (i = 0; i < ELEMENT_COUNT ; i = i +1 ) begin

            if (i==0) begin
                IntegerComparison #(.ELEMENT_SIZE(ELEMENT_SIZE)) IC(
                .a(in[0 +: ELEMENT_SIZE]),
                .b(in[ELEMENT_SIZE +: ELEMENT_SIZE]),
                .clk(clk),
                .result(largestelement[0]));
            end
            else begin
                IntegerComparison #(.ELEMENT_SIZE(ELEMENT_SIZE)) IC(
                    .a(in[ELEMENT_SIZE *(i) +: ELEMENT_SIZE]),
                    .b(largestelement[i-1]),
                    .clk(clk),
                    .result(largestelement[i]));  
            end
        end
    endgenerate
    assign result = largestelement[ELEMENT_COUNT-1];
endmodule;

module IntegerComparison #(parameter ELEMENT_SIZE = 32)
                          (input [ELEMENT_SIZE-1:0] a,
                           input [ELEMENT_SIZE-1:0] b,
                           input                    clk,
                           output reg[ELEMENT_SIZE-1:0] result);
        
    always @(*) begin
        if (a > b) begin
            assign result = a;
        end
        else begin
            assign result = b;
        end
    end
endmodule


//iverilog -o LargestElementofArrayTB.vvp LargestElementofArrayTB.v
// vvp LargestElementofArrayTB.vvp  