`timescale 1ns / 1ps

`include "NeuralNetworkNew.v"

module NeuralNetworkNewTB;
    parameter NR_LAYERS = 2, INPUTSIZE = 4, OUTPUTSIZE = 10, MAXWEIGHTS= 4, MAXRESULTS= 10;
    reg [INPUTSIZE*32-1:0] imagedata;
    reg [32*NR_LAYERS-1:0] neuroncount = {32'd10,32'd3};                                
    wire [32*OUTPUTSIZE-1:0] result;

    reg clk = 0;
    always begin
       clk = ~clk;
       #1;
    end

    NeuralNetworkNew #(.NR_LAYERS(NR_LAYERS),
                    .INPUTSIZE(INPUTSIZE),
                    .OUTPUTSIZE(OUTPUTSIZE),
                    .MAXWEIGHTS(MAXWEIGHTS),
                    .MAXRESULTS(MAXRESULTS)) 
                    NN1 (
                        .inputdata(imagedata),
                        .neuron_count(neuroncount),
                        .clk(clk),
                        .result(result));

    initial
    begin
        $dumpfile("NeuralNetworkNewTB.vcd");
        $dumpvars(0,NeuralNetworkNewTB);

        imagedata = {32'h41200000,32'h41200000,32'h41200000,32'h41200000};
        
        #1000;
        $finish;
    end
    
endmodule