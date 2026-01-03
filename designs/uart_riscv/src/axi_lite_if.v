module axi_lite_if #(
    parameter ADDR_WIDTH = 4,
    parameter DATA_WIDTH = 32
)(
    input wire clk, rst_n,
    // AXI4-Lite Slave Interface
    input  wire [ADDR_WIDTH-1:0] awaddr,
    input  wire awvalid,
    output reg  awready,
    input  wire [DATA_WIDTH-1:0] wdata,
    input  wire [3:0] wstrb,
    input  wire wvalid,
    output reg  wready,
    output reg  [1:0] bresp,
    output reg  bvalid,
    input  wire bready,
    input  wire [ADDR_WIDTH-1:0] araddr,
    input  wire arvalid,
    output reg  arready,
    output reg  [DATA_WIDTH-1:0] rdata,
    output reg  [1:0] rresp,
    output reg  rvalid,
    input  wire rready,
    
    // Internal Interface
    output reg [ADDR_WIDTH-1:0] reg_addr,
    output reg [7:0] reg_wdata,
    output reg reg_we,
    output reg reg_re,
    input  wire [7:0] reg_rdata
);

    // State Machine for Simple Handshaking
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            awready <= 0; wready <= 0; bvalid <= 0;
            arready <= 0; rvalid <= 0;
            reg_we <= 0; reg_re <= 0;
        end else begin
            // Write Channel
            reg_we <= 0;
            if (awvalid && wvalid && !awready && !wready) begin
                awready <= 1;
                wready <= 1;
                reg_addr <= awaddr;
                reg_wdata <= wdata[7:0];
                reg_we <= 1;
                bvalid <= 1;
                bresp <= 0; // OKAY
            end else begin
                awready <= 0;
                wready <= 0;
                if (bready && bvalid) bvalid <= 0;
            end

            // Read Channel
            reg_re <= 0;
            if (arvalid && !arready) begin
                arready <= 1;
                reg_addr <= araddr;
                reg_re <= 1;
            end else if (arready && !rvalid) begin
                arready <= 0;
                rvalid <= 1;
                rdata <= {24'b0, reg_rdata};
                rresp <= 0; // OKAY
            end else if (rready && rvalid) begin
                rvalid <= 0;
            end
        end
    end
endmodule