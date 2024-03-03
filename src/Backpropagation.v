`timescale 1ns / 1ps

`include "FloatingDivision.v"
`include "FloatingMultiplication.v"
`include "FloatingAddition.v"
`include "Sigmoid_derivative.v"
`include "VectorMultiplicationFlex.v"

`define PACK_ARRAY(PK_WIDTH,PK_LEN,PK_SRC,PK_DEST,PK_IDX) \
for (genvar PK_IDX=0; PK_IDX<(PK_LEN); PK_IDX=PK_IDX+1) begin \
    assign PK_DEST[(PK_WIDTH)*PK_IDX +: PK_WIDTH] = PK_SRC[PK_IDX][((PK_WIDTH)-1):0]; \
end

module Backpropagation (# parameter NR_LAYERS = 2, OUTPUTSIZE = 10,MAXWEIGHTS = 784, MAXRESULTS= 15)
                       (input [31:0] epsilon,
                        input clk,
                        input [(32 * (NR_LAYERS + 1)) - 1: 0]  neuron_count, // also with neuroncount of input layer
                        input [(32 * OUTPUTSIZE) - 1: 0] actual_result,
                        input [(32 * OUTPUTSIZE) - 1: 0] wanted_result,
                        input [(32 * MAXRESULTS * NR_LAYERS) -1:0] activation_levels, //weighted sum of all inputs
                        input [(32 * MAXRESULTS * NR_LAYERS) -1:0] net_input,
                        output [(32 * MAXRESULTS * NR_LAYERS) -1:0] changes,
                        output finished,
                       );

wire [32*MAXWEIGHTS*MAXRESULTS-1:0] weightstorage;
reg [31:0] weightstorage_2dim [MAXWEIGHTS*MAXRESULTS-1:0];
`PACK_ARRAY(32, MAXWEIGHTS*MAXRESULTS,weightstorage_2dim,weightstorage,PACK1);

// wire [32*MAXRESULTS-1:0] biasstorage;
// reg [31:0] biasstorage_2dim [MAXRESULTS-1:0];
// `PACK_ARRAY(32, MAXRESULTS,biasstorage_2dim,biasstorage,PACK2);

integer layerindex = NR_LAYERS;
reg [31:0] curr_neuroncount;
reg [31:0] curr_connectioncount;

reg [32*MAXRESULTS -1: 0] curr_activation_levels;
wire [32*MAXWEIGHTS*MAXRESULTS-1:0] changes_1;
wire [32*MAXWEIGHTS*MAXRESULTS-1:0] changes_2;
wire [32*MAXWEIGHTS*MAXRESULTS-1:0] changes_3;

wire [32*MAXWEIGHTS-1:0] delta_values;
wire [32*MAXWEIGHTS-1:0] delta_values_old;
wire [32*MAXRESULTS-1:0] curr_deltas;
wire [32*MAXRESULTS-1:0] Sigmoid_derivatives;
wire [32*MAXRESULTS-1:0] activation_differences;
wire [32*MAXRESULTS-1:0] delta_weight_sums;


always @(layerindex) begin
    curr_neuroncount <= neuron_count[32*(layerindex)+:32];
    curr_connectioncount <= curr_connectioncount[32*(layerindex-1)+:32];
    curr_activation_levels <= activation_levels[(32 * MAXRESULTS * (NR_LAYERS-1)) +: (32 * MAXRESULTS)];
    $readmemb($sformatf("%s%1d%s", "Weights_folder/weights_", layerindex-1,".mem"), weightstorage_2dim);
     

    // Step1: loads epsilon into the wire
    genvar i; generate for (i = 0; i < MAXWEIGHTS*MAXRESULTS; i = i +1) begin changes_1[32* i +:32] = epsilon; end endgenerate;

    // Step2: multiply with the activation-level of every Neuron
    genvar neuron_nr; genvar weight_nr; generate
        for (neuron_nr = 0; neuron_nr < MAXRESULTS; neuron_nr = neuron_nr + 1) begin 
            for (weight_nr = 0; weight_nr < MAXWEIGHTS; weight_nr = weight_nr +1) begin
                FloatingMultiplication mult1(.A(changes_1[32*neuron_nr*MAXWEIGHTS+32*weight_nr +:32]),
                 .B(curr_activation_levels[32*neuron_nr +:32]), .result(changes_2[32*neuron_nr*MAXWEIGHTS+32*weight_nr +:32]));
            end end endgenerate;


    if(layerindex == NR_LAYERS) begin // Case: OUTPUT LAYER
        // Step3: calculate derivative Function and activation differences
        genvar neuron_nr2; genvar weight_nr2; generate
            for (neuron_nr2 = 0; neuron_nr2 < MAXRESULTS ; neuron_nr2 = neuron_nr2+1) begin
                Sigmoid_derivative sd1(.num(net_input[32*MAXWEIGHTS*(NR_LAYERS-1)+32*neuron_nr2+:32]),
                                       .result(Sigmoid_derivatives[neuron_nr2*32+:32]));
                FloatingAddition diff(.A(wanted_result[32*neuron_nr2 +:32]), .B({~actual_result[32*neuron_nr2+31+:1],actual_result[32*neuron_nr2 +:31]}),
                                  .result(activation_differences[32*neuron_nr2 +:32])); // Let Simon check on the B composition again
                FloatingMultiplication mult2(.A(Sigmoid_derivatives[neuron_nr2*32+:32]),
                                             .B(activation_differences[32*neuron_nr2 +:32]),
                                             .result(delta_values_old[32*neuron_nr2 +:32]));
            end endgenerate;

        genvar neuron_nr3; genvar weight_nr3; generate
            for (neuron_nr3 = 0; neuron_nr3 < MAXRESULTS; neuron_nr3 = neuron_nr3 + 1) begin 
                for (weight_nr3 = 0; weight_nr3 < MAXWEIGHTS; weight_nr3 = weight_nr3 +1) begin
                    FloatingMultiplication mult3(.A(changes_2[32*neuron_nr3*MAXWEIGHTS+32*weight_nr3 +:32]), 
                                                 .B(delta_values_old[32*neuron_nr3*:32]),
                                                 .result(changes_3[32*neuron_nr3*MAXWEIGHTS+32*weight_nr3 +:32]));
            end end endgenerate;
        layerindex = layerindex - 1;
    end
    else if (layerinde > 0) begin
        genvar neuron_nr4; generate
            for (neuron_nr4 = 0; neuron_nr4 < MAXRESULTS ; neuron_nr4 = neuron_nr4 + 1 ) begin
                Sigmoid_derivative sd2(.num(net_input[32*MAXWEIGHTS*(NR_LAYERS-1)+32*neuron_nr4+:32]),
                                       .result(Sigmoid_derivatives[neuron_nr4*32+:32]));
                VectorMultiplicationFlex #(.BUFLEN(MAXRESULTS)) 
                V1(.A(delta_values_old),
                    .B(weightstorage[32*MAXWEIGHTS*neuron_nr4+:32*MAXWEIGHTS]), //different mechanism for storing weights
                    .clk(clk) ,.vlen(neuron_count[32*(layerindex+1)+:32]),.result(delta_weight_sums[32*neuron_nr4+:32]));
                FloatingMultiplication mult3(.A(Sigmoid_derivatives[32*neuron_nr4+:32]),
                                             .B(delta_weight_sums[32*neuron_nr4+:32]),
                                             .result(delta_values[32*neuron_nr4+:32]));
            end endgenerate;

        genvar neuron_nr5; genvar weight_nr5; generate
            for (neuron_nr5 = 0; neuron_nr5 < MAXRESULTS; neuron_nr5 = neuron_nr5 + 1) begin 
                for (weight_nr5 = 0; weight_nr5 < MAXWEIGHTS; weight_nr5 = weight_nr5 +1) begin

                    FloatingMultiplication mult4(.A(changes_2[32*neuron_nr5*MAXWEIGHTS+32*weight_nr5 +:32]), 
                                                 .B(delta_values[32*neuron_nr5*:32]),
                                                 .result(changes_3[32*neuron_nr3*MAXWEIGHTS+32*weight_nr3 +:32]));
            end end endgenerate;
    
        delta_values_old = delta_values;
        layerindex = layerindex - 1;

    end 
    else begin 
        changes = changes_3
        finished = 1'b1;
    end
end
endmodule




