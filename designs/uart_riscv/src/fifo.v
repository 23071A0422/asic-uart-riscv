`timescale 1ns / 1ps
module fifo #(
    parameter DATA_WIDTH = 8,
    parameter ADDR_WIDTH = 4
)(
    input  wire wclk, wrst_n,
    input  wire winc,
    input  wire [DATA_WIDTH-1:0] wdata,
    output wire wfull,

    input  wire rclk, rrst_n,
    input  wire rinc,
    output reg  [DATA_WIDTH-1:0] rdata,
    output wire rempty
);

    localparam DEPTH = 1 << ADDR_WIDTH;
    reg [DATA_WIDTH-1:0] mem [0:DEPTH-1];

    reg [ADDR_WIDTH:0] wptr_bin, wptr_gray;
    reg [ADDR_WIDTH:0] rptr_bin, rptr_gray;

    reg [ADDR_WIDTH:0] wptr_gray_r1, wptr_gray_r2;
    reg [ADDR_WIDTH:0] rptr_gray_r1, rptr_gray_r2;

    function [ADDR_WIDTH:0] bin2gray(input [ADDR_WIDTH:0] b);
        bin2gray = (b >> 1) ^ b;
    endfunction

    // === WRITE DOMAIN ===
    wire [ADDR_WIDTH:0] wptr_bin_next = wptr_bin + (winc && !wfull);
    wire [ADDR_WIDTH:0] wptr_gray_next = bin2gray(wptr_bin_next);

    always @(posedge wclk or negedge wrst_n) begin
        if (!wrst_n) begin
            wptr_bin <= 0;
            wptr_gray <= 0;
        end else begin
            if (winc && !wfull)
                mem[wptr_bin[ADDR_WIDTH-1:0]] <= wdata;
            wptr_bin <= wptr_bin_next;
            wptr_gray <= wptr_gray_next;
        end
    end

    // === READ DOMAIN ===
    wire [ADDR_WIDTH:0] rptr_bin_next = rptr_bin + (rinc && !rempty);
    wire [ADDR_WIDTH:0] rptr_gray_next = bin2gray(rptr_bin_next);

    // === READ DOMAIN ===
assign rdata = mem[rptr_bin[ADDR_WIDTH-1:0]];

always @(posedge rclk or negedge rrst_n) begin
    if (!rrst_n) begin
        rptr_bin <= 0;
        rptr_gray <= 0;
    end else if (rinc && !rempty) begin
        rptr_bin <= rptr_bin_next;
        rptr_gray <= rptr_gray_next;
    end
end


    // === POINTER SYNC ===
    always @(posedge wclk or negedge wrst_n)
        if (!wrst_n) {rptr_gray_r2, rptr_gray_r1} <= 0;
        else {rptr_gray_r2, rptr_gray_r1} <= {rptr_gray_r1, rptr_gray};

    always @(posedge rclk or negedge rrst_n)
        if (!rrst_n) {wptr_gray_r2, wptr_gray_r1} <= 0;
        else {wptr_gray_r2, wptr_gray_r1} <= {wptr_gray_r1, wptr_gray};

    // === FLAGS ===
    // === FLAGS ===
assign rempty = (rptr_gray == wptr_gray_r2);


assign wfull = (wptr_gray_next ==
    {~rptr_gray_r2[ADDR_WIDTH:ADDR_WIDTH-1],
      rptr_gray_r2[ADDR_WIDTH-2:0]});


endmodule