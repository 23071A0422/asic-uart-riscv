// S+++ Tier: Top-Level ASIC Integration (Fixed Internal Routing)
`timescale 1ns / 1ps

module uart_riscv_top (
    input  wire        clk,
    input  wire        rst_n,
    input  wire        uart_rx,
    output wire        uart_tx,
    // External MTJ control for TB
    input  wire        mtj_write_en,
    output wire [7:0]  mtj_data_out
);

    // Internal AXI Signals connecting RISC-V to UART
    wire [3:0]  int_axi_awaddr;
    wire [31:0] int_axi_wdata;
    wire        int_axi_wvalid;
    wire        int_axi_wready;

    // 1. Tiny RISC-V Master (Driving the internal bus)
    riscv_tiny_proc u_cpu (
        .clk(clk), .rst_n(rst_n),
        .axi_awaddr(int_axi_awaddr),
        .axi_wdata(int_axi_wdata),
        .axi_wvalid(int_axi_wvalid),
        .axi_wready(int_axi_wready)
    );

    // 2. AXI4-Lite UART Slave
    uart_top u_uart (
        .clk(clk), .rst_n(rst_n),
        .s_axi_awaddr(int_axi_awaddr), .s_axi_awvalid(int_axi_wvalid), .s_axi_awready(int_axi_wready),
        .s_axi_wdata(int_axi_wdata), .s_axi_wstrb(4'b1111), .s_axi_wvalid(int_axi_wvalid), .s_axi_wready(),
        .s_axi_bresp(), .s_axi_bvalid(), .s_axi_bready(1'b1),
        .rx(uart_rx), .tx(uart_tx),
        .interrupt()
    );

    // 3. Spintronic MTJ Cell (Connected to the INTERNAL bus)
    sky130_fd_sc_hd__mtj_1 u_mtj_nvm (
        .clk(clk),
        .write_en(mtj_write_en),
        .din(int_axi_wdata[7:0]), // Now connected to internal RISC-V data
        .dout(mtj_data_out)
    );

endmodule