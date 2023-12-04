`timescale 1ns / 1ps

// https://en.wikipedia.org/wiki/Advanced_eXtensible_Interface#Writes

// Writes n-th element of a vector (length VLEN) to the memory with designated address. Assumes 32bit memory element size and 32bit addresses.
// Performs VLEN write operations on clock cycles whenever input changes. For stale input, no memory writes are performed.
// Works only for VLEN < 256 as it assumes all data fits into one burst.
module Vector2AXI #(VLEN = 1, START_ADDR = 'hA000_0000, MEM_SIZE = 'h1FFF)
                        (input clk,
                        input[(32 * VLEN) - 1:0] vec,

                        output [31:0] aw_addr,
                        output [2:0] aw_size,
                        output [7:0] aw_len,
                        output [1:0] aw_burst,
                        output reg aw_valid,
                        input      aw_ready,

                        output reg[31:0] w_data,
                        output reg w_valid,
                        input      w_ready,
                        output reg w_last,

                        input [1:0] b_resp,
                        input      b_valid,
                        output reg b_ready);
    reg [7:0] process_step;  // different steps of transmission
    reg [1:0] b_resp_cache;  // recieve response correctly first, then react to it
    integer idx;

    // https://web.archive.org/web/20190705083043/https://static.docs.arm.com/ihi0022/e/IHI0022E_amba_axi_and_ace_protocol_spec.pdf
    // Pages A3-46 to 48
    assign aw_addr = START_ADDR;  // start of the burst, therefore constant
    assign aw_size = 3'b010;  // 4 bytes per beat
    assign aw_len = VLEN;     // entire input vector as 1 burst (VLEN < 256 !!!)
    assign aw_burst = 2'b01;  // INCR

    initial begin
        process_step <= 'b1;
        idx <= 0;

        aw_valid <= 1'b0;
        w_data <= 32'b0;  // remove hi-z/undefined
        w_valid <= 1'b0;
        w_last <= 1'b0;
    end

    // reset when input data changes
    always @ (vec) begin
        process_step <= 'b1;
        idx <= 0;

        aw_valid <= 1'b0;
        // w_data not necessary, we are not transmitting
        w_valid <= 1'b0;
        w_last <= 1'b0;
    end

    // send address (validate aw bus)
    always @ (posedge clk & process_step[0]) begin
        aw_valid <= 1'b1;
        process_step <= process_step << 1;
    end

    // confirm received address
    always @ (posedge aw_ready & process_step[1]) begin
        aw_valid <= 1'b0;
        process_step <= process_step << 1;
    end

    // send first data beat (validate w bus)
    always @ (posedge clk & process_step[2]) begin
        w_data <= vec[31:0];  // == [32 * 0 +: 32]
        w_valid <= 1'b1;
        idx <= 1;
        process_step <= process_step << 1;
    end

    // confirm received data, send next beat every clock cycle (until the last one)
    always @ (posedge clk & w_ready & process_step[3]) begin
        w_data <= vec[32 * idx +: 32];
        idx <= idx + 1;

        if (idx >= VLEN - 1) begin  // we just sent last beat
            w_last <= 1'b1;
            process_step <= process_step << 1;
        end
    end

    // terminate data sending process
    always @ (posedge clk & process_step[4]) begin
        w_data <= 32'b0;
        w_last <= 1'b0;
        w_valid <= 1'b0;

        idx <= 0;
        process_step <= process_step << 1;
    end

    // receive write response
    always @ (posedge b_valid & process_step[5]) begin
        b_ready <= 1'b1;
        b_resp_cache <= b_resp;

        // hi bit of b_resp indicates error
        // in case of error, return to 1st step (sending address)
        process_step <= process_step << 1;
    end

    // react to write response
    always @ (posedge clk & process_step[6]) begin
        b_ready <= 1'b0;

        // high bit of b_resp indicates error
        // in case of error, return to 1st step (sending address)
        process_step <= (b_resp_cache[1]) ? 'b1 : process_step << 1;
    end

endmodule