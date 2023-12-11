`timescale 1ns / 1ns

`include "MatrixMultiplicationSeq.v"
`include "VectorAddition.v"
`include "ReLU.v"
`include "Sigmoid.v"
`include "Softmax.v"
`include "HyperbolicTangent.v"
`include "Softplus.v"
`include "NeuralLayerSeq.v"
`include "MatrixMultiplicationFlex.v"
`include "LargestElementofArray.v"
`include "VectorAdditionFlex.v"

// https://stackoverflow.com/questions/31010070/verilog-vector-packing-unpacking-macro
`define PACK_ARRAY(PK_WIDTH,PK_LEN,PK_SRC,PK_DEST,PK_IDX) \
for (genvar PK_IDX=0; PK_IDX<(PK_LEN); PK_IDX=PK_IDX+1) begin \
    assign PK_DEST[(PK_WIDTH)*PK_IDX +: PK_WIDTH] = PK_SRC[PK_IDX][((PK_WIDTH)-1):0]; \
end


module NeuralNetworkNew #(parameter NR_LAYERS = 2, INPUTSIZE = 4, OUTPUTSIZE = 10, MAXWEIGHTS= 4, MAXNEURONS= 10)
                        (input [(32 * INPUTSIZE) - 1: 0]  inputdata,
                        input [(32 * NR_LAYERS) - 1: 0]  net_arch,
                        input                            clk,
                        output reg[(32 * OUTPUTSIZE) - 1: 0] result);

wire [32*MAXNEURONS -1:0] currentresult;        
wire [32*MAXNEURONS-1:0] mul_store; 
wire [32*MAXNEURONS-1:0] add_store; 
reg [32*MAXNEURONS-1:0] data_store;

wire [32*MAXWEIGHTS*MAXNEURONS-1:0] weightstorage;
wire [32*MAXNEURONS-1:0] biasstorage;
reg [31:0] weightstorage_2dim [MAXWEIGHTS*MAXNEURONS-1:0];
reg [31:0] biasstorage_2dim [MAXNEURONS-1:0];

integer layerindex = 0;
reg [31:0] input_cnt;
reg [31:0] neuron_cnt;
wire donemul, doneadd;

`PACK_ARRAY(32, MAXWEIGHTS*MAXNEURONS,weightstorage_2dim,weightstorage,PACK1);
`PACK_ARRAY(32, MAXNEURONS,biasstorage_2dim,biasstorage,PACK2);

MatrixMultiplicationFlex #( .LBUF(MAXNEURONS),
                            .MBUF(MAXWEIGHTS),
                            .NBUF(1),
                            .MOD_COUNT(1))
                            M1(
                                .A(weightstorage),
                                .B_T(data_store),
                                .clk(clk),
                                .l(neuron_cnt),
                                .m(input_cnt),
                                .n(1),
                                .result(mul_store),
                                .done(donemul));

VectorAdditionFlex #( .LBUF(MAXNEURONS)) 
                            VA1 (
                                .A(mul_store),
                                .B(biasstorage),
                                .clk(clk),
                                .l(neuron_cnt),
                                .prevmuldone(donemul),
                                .result(add_store),
                                .done(doneadd));

genvar i;
generate
    for(i = 0; i < MAXNEURONS; i = i + 1)
        Sigmoid sigmoid(.num(add_store[32 * i +: 32]), .result(currentresult[32 * i +: 32]));
endgenerate 

always @(doneadd) begin
    if (layerindex >= NR_LAYERS) begin 
        result = currentresult;
    end 
    else begin
        $readmemb($sformatf("%s%1d%s", "Weights_folder/weights_", layerindex,".mem"), weightstorage_2dim);
        $readmemb($sformatf("%s%1d%s", "Bias_folder/biases_", layerindex,".mem"),biasstorage_2dim);
        layerindex = layerindex + 1;
        if (layerindex == 1) begin
            result <= 0;
            data_store <= inputdata[0+:INPUTSIZE*32];
            input_cnt <= INPUTSIZE;
            neuron_cnt <= net_arch[0+:32];
        end
        else begin
            data_store <= currentresult; 
            input_cnt <= neuron_cnt;
            neuron_cnt <= net_arch [(layerindex-1)*32+:32];
        end
    end
end

endmodule