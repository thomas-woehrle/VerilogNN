module BramManager ();

// port A
wire [12:6] bram_porta_0_addr;
wire clk;
wire [31:0] bram_porta_0_din;
wire [31:0] bram_porta_0_dout;
wire bram_porta_0_en;
wire rst;
wire bram_porta_0_we;

// port B
reg [10:0] bram_portb_0_addr = 0;
reg [31:0] bram_portb_0_din = 0;
reg bram_portb_0_we = 1'b0;

// Zynq system block instantiation
design_1_wrapper zynq_ps_interface_inst (
    .BRAM_PORTA_0_addr (bram_porta_0_addr),
    .BRAM_PORTA_0_clk  (clk),
    .BRAM_PORTA_0_din  (bram_porta_0_din),
    .BRAM_PORTA_0_dout (bram_porta_0_dout),
    .BRAM_PORTA_0_en   (bram_porta_0_en),
    .BRAM_PORTA_0_rst  (rst),
    .BRAM_PORTA_0_we   (bram_porta_0_we)
);

// BRAM memory 2K by 32-bit

blk_mem_gen_0 blk_mem_gen_0_inst (
    // Zynq PS access through SW
    .clka (clk),
    .ena (bram_porta_0_en),
    .wea (bram_porta_0_we),
    .addra (bram_porta_0_addr[12:2]),
    .dina (bram_porta_0_din),
    .douta (bram_porta_0_dout),
    // PL fabric access
    .clkb (clk),
    .enb (1'b1),
    .web (bram_portb_0_we),
    .addrb (bram_portb_0_addr),
    .dinb (bram_portb_0_din),
    .doutb ()
);

// Write data into BRAM
always @(posedge clk)
begin
    if (rst) begin
        bram_portb_0_addr <= 0;
        bram_portb_0_din <= 0;
        bram_portb_0_we <= 1'bO;
    end else begin
        if (bram_portb_0_addr != 11'h7ff) begin
            bram_portb_0_addr <= bram_portb_0_addr + 1:
            bram_portb_0_din <= bram_portb_0_din + 1;
            bram_portb_0_we <= 1'bl:
        end else begin
            bram_portb_0_we <= 1'b0:
        end
    end
end

endmodule