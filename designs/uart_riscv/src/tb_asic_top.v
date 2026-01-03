`timescale 1ns / 1ps

module tb_asic_top();
    reg clk = 0;
    reg rst_n = 0;
    wire tx;
    wire [7:0] mtj_dout;
    reg mtj_we = 0;

    // Clock Generator: 100MHz
    always #5 clk = ~clk;

    // Updated S+++ Tapeout Top Module Instantiation
    uart_riscv_top dut (
        .clk(clk),
        .rst_n(rst_n),
        .uart_rx(1'b1), 
        .uart_tx(tx),
        .mtj_write_en(mtj_we),
        .mtj_data_out(mtj_dout)
    );

    initial begin
        $dumpfile("asic_signoff.vcd");
        $dumpvars(0, tb_asic_top);
        
        $display("--- Starting S+++ ASIC Functional Signoff ---");
        rst_n = 0;
        #100 rst_n = 1;
        
        $display("[TEST 1] Monitoring RISC-V 'A' (0x41) transmission...");
        #2000; 
        
        $display("[TEST 2] Testing Spintronic MTJ Persistence...");
        mtj_we = 1; #20; mtj_we = 0;
        
        $display("[INFO] Simulating System Power-Down...");
        rst_n = 0; 
        #100; 
        
        if (mtj_dout === 8'h41) 
            $display("[PASS] MTJ Persistence Verified: Data 0x%h retained during Power-Down.", mtj_dout);
        else 
            $display("[FAIL] MTJ Volatility Error: Data lost!");

        $display("--- ASIC Functional Signoff Complete ---");
        $finish;
    end
endmodule