module uart_top(
    input wire clk, rst_n,
    // AXI4-Lite
    input  wire [3:0] s_axi_awaddr,
    input  wire s_axi_awvalid,
    output wire s_axi_awready,
    input  wire [31:0] s_axi_wdata,
    input  wire [3:0] s_axi_wstrb,
    input  wire s_axi_wvalid,
    output wire s_axi_wready,
    output wire [1:0] s_axi_bresp,
    output wire s_axi_bvalid,
    input  wire s_axi_bready,
    input  wire [3:0] s_axi_araddr,
    input  wire s_axi_arvalid,
    output wire s_axi_arready,
    output wire [31:0] s_axi_rdata,
    output wire [1:0] s_axi_rresp,
    output wire s_axi_rvalid,
    input  wire s_axi_rready,
    // UART Physical
    input  wire rx,
    output wire tx,
    output wire interrupt
);

    // Internal Signals
    wire [3:0] reg_addr;
    wire [7:0] reg_wdata;
    wire reg_we, reg_re;
    reg [7:0] reg_rdata;
    
    // Registers
    reg [7:0] DLL = 1; // Divisor Latch LSB
    reg [7:0] DLM = 0; // Divisor Latch MSB
    reg [7:0] IER = 0;
    reg [7:0] LCR = 0; // Line Control
    reg [7:0] FCR = 0; // FIFO Control
    reg [7:0] MCR = 0;
    reg [7:0] SCR = 0;
    
    
    // Status
    wire lsr_dr, lsr_thre, lsr_temt, lsr_oe, lsr_pe, lsr_fe;
    
    // Modules
    wire tick_16x;
    wire [15:0] divisor = {DLM, DLL};
    
    baud_gen u_bg(.clk(clk), .rst_n(rst_n), .divisor(divisor), .tick_16x(tick_16x));
    
    // FIFOs
    wire tx_fifo_full, tx_fifo_empty;
    wire rx_fifo_full, rx_fifo_empty;
    wire [7:0] tx_din, rx_dout;  
    wire tx_wr, rx_rd;

    // RX FIFO read pipeline (FIX)


    
    // TX Path
    // TX Path
wire tx_done, tx_busy;
reg tx_start_reg;
wire [7:0] tx_fifo_out;

reg [7:0] tx_hold;   // <<< ADD
reg tx_prefetch;     // <<< ADD

    
    fifo #(.DATA_WIDTH(8)) u_tx_fifo (
        .wclk(clk), .wrst_n(rst_n), .winc(tx_wr), .wdata(tx_din), .wfull(tx_fifo_full),
        .rclk(clk), .rrst_n(rst_n), .rinc(tx_start_reg), .rdata(tx_fifo_out), .rempty(tx_fifo_empty)
    );
    
    uart_tx u_tx (
        .clk(clk), .rst_n(rst_n), .tick_16x(tick_16x),
        .din(tx_hold), .tx_start(tx_start_reg), .lcr({LCR[2], LCR[4], LCR[3]}),
        .tx(tx), .tx_done(tx_done), .tx_busy(tx_busy)
    );
    
    // TX State Machine: Pull from FIFO when UART TX is idle
    // TX State Machine with FIFO prefetch (FIXED)
reg tx_active;
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        tx_start_reg <= 0;
        tx_active    <= 0;
        tx_prefetch  <= 0;
        tx_hold      <= 0;
    end else begin
        tx_start_reg <= 0;

        // Step 1: request FIFO read
        if (!tx_active && !tx_fifo_empty && !tx_prefetch) begin
            tx_prefetch <= 1;
        end

        // Step 2: latch FIFO data AFTER read
        if (tx_prefetch) begin
            tx_hold     <= tx_fifo_out;
            tx_start_reg <= 1;
            tx_active   <= 1;
            tx_prefetch <= 0;
        end

        if (tx_done)
            tx_active <= 0;
    end
end

    
    // RX Path
    wire [7:0] rx_byte;
    wire rx_byte_done, rx_frame_err, rx_parity_err;
    
    uart_rx u_rx (
        .clk(clk), .rst_n(rst_n), .tick_16x(tick_16x),
        .rx(rx), .lcr({LCR[2], LCR[4], LCR[3]}), .dout(rx_byte),
        .rx_done(rx_byte_done), .frame_err(rx_frame_err), .parity_err(rx_parity_err)
    );
    
    fifo #(.DATA_WIDTH(8)) u_rx_fifo (
        .wclk(clk), .wrst_n(rst_n), .winc(rx_byte_done && !rx_fifo_full), .wdata(rx_byte), .wfull(rx_fifo_full),
        .rclk(clk), .rrst_n(rst_n), .rinc(rx_rd), .rdata(rx_dout), .rempty(rx_fifo_empty)
    );

    // Register Read/Write Logic (16550 Map)
    wire dlab = LCR[7];
    
    // Write Decode
    assign tx_wr = (reg_we && reg_addr == 0 && !dlab && !tx_fifo_full);
    assign tx_din = reg_wdata;
    
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            DLL <= 1; DLM <= 0; IER <= 0; LCR <= 0; FCR <= 0; MCR <= 0; SCR <= 0;
        end else if (reg_we) begin
            case (reg_addr)
                0: if (dlab) DLL <= reg_wdata; // Else writing to THR (handled by FIFO)
                1: if (dlab) DLM <= reg_wdata; else IER <= reg_wdata;
                2: FCR <= reg_wdata;
                3: LCR <= reg_wdata;
                4: MCR <= reg_wdata;
                7: SCR <= reg_wdata;
            endcase
        end
    end
    
    // Read Decode
    assign rx_rd = (reg_re && reg_addr == 0 && !dlab && !rx_fifo_empty);

    
    always @(*) begin
        case (reg_addr)
            0: reg_rdata = dlab ? DLL : rx_dout;
            1: reg_rdata = dlab ? DLM : IER;
            2: reg_rdata = 8'hC1; // IIR (Simulated ID)
            3: reg_rdata = LCR;
            4: reg_rdata = MCR;
            5: reg_rdata = {rx_frame_err, 1'b0, 1'b0, rx_parity_err, rx_frame_err, tx_fifo_empty && !tx_active, tx_fifo_empty, !rx_fifo_empty}; // LSR
            6: reg_rdata = 0; // MSR
            7: reg_rdata = SCR;
            default: reg_rdata = 0;
        endcase
    end

    // AXI Instantiation
    axi_lite_if u_axi (
        .clk(clk), .rst_n(rst_n),
        .awaddr(s_axi_awaddr), .awvalid(s_axi_awvalid), .awready(s_axi_awready),
        .wdata(s_axi_wdata), .wstrb(s_axi_wstrb), .wvalid(s_axi_wvalid), .wready(s_axi_wready),
        .bresp(s_axi_bresp), .bvalid(s_axi_bvalid), .bready(s_axi_bready),
        .araddr(s_axi_araddr), .arvalid(s_axi_arvalid), .arready(s_axi_arready),
        .rdata(s_axi_rdata), .rresp(s_axi_rresp), .rvalid(s_axi_rvalid), .rready(s_axi_rready),
        .reg_addr(reg_addr), .reg_wdata(reg_wdata), .reg_we(reg_we), .reg_re(reg_re), .reg_rdata(reg_rdata)
    );

endmodule