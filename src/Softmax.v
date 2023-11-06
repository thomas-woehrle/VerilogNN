`include "E_Function.v"
`include "VectorSum.v"
`include "src/FloatingDivision.v"

module Softmax #(parameter SIZE = 4) // IN SIZE should be equal to out size since each value gets a probability
                (input [(32 * SIZE) - 1 : 0]    in,
                 output [(32 * SIZE) - 1 : 0]   result);

    wire [(32*SIZE) -1: 0] E_storage;
    wire [31:0] sum;
    wire zerodivision;
    wire [(32*SIZE) -1: 0] probability_storage;

    genvar i;
    generate
        for(i = 0; i <SIZE; i = i +1) begin
            e_function E1 (.x_value(in[32 * i +:32]), .result(E_storage[32 * i +: 32]));
        end
    endgenerate

    VectorSum V1(.Vector(E_storage), .result(sum));

    genvar j;
    generate
        for(j = 0; j <SIZE; j = j +1) begin
            FloatingDivision F1 (.A(E_storage[32 * j +: 32]),
                                 .B(sum),
                                 .zero_division(zerodivision),
                                 .result(probability_storage[32 * j +: 32]));
        end
    endgenerate

    // probably some safety measures regarding Zero Div still needed !
    assign result = probability_storage; 
endmodule
