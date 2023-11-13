`include "E_Function.v"
`include "VectorSum.v"
`include "FloatingDivision.v"

module HyperbolicTangent(input    [31:0] num,
                         output   [31:0] result);
    
    wire [31:0] one = 32'b0_01111111_00000000000000000000000; 
    wire [31:0] E_storage;
    wire [31:0] E_inverse;
    wire zerodivision;


    wire [31:0] num_flipped;
    assign num_flipped  = {~num[31],num[30:0]};
   
    wire [31:0] numerator;//zähler
    wire [31:0] denominator;
    wire [31:0] fraction;

    e_function E1 (.x_value(num),
                   .result(E_storage));

    e_function E2 (.x_value(num_flipped),
                   .result(E_inverse));     

    wire [31:0] E_inverse_flipped;
    assign E_inverse_flipped  = {~E_inverse[31],E_inverse[30:0]};

    FloatingAddition A1(.A(E_storage),
                        .B(E_inverse),
                        .result(numerator)); 
    
    FloatingAddition A2(.A(E_storage),
                        .B(E_inverse_flipped),
                        .result(denominator));
     
    FloatingDivision F2(.A(numerator),
                        .B(denominator),
                        .zero_division(zero_division),
                        .result(fraction));

    assign result = fraction;
endmodule

