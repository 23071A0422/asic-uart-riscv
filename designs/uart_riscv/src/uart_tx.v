module uart_tx(
    input wire clk, rst_n,
    input wire tick_16x,
    input wire [7:0] din,
    input wire tx_start,
    input wire [2:0] lcr, // {parity_en, parity_type, stop_bits}
    output reg tx,
    output reg tx_done,
    output reg tx_busy
);
    // LCR[2]: 0=1 stop, 1=2 stop
    // LCR[1]: 0=Odd, 1=Even
    // LCR[0]: Parity Enable

    localparam IDLE=0, START=1, DATA=2, PARITY=3, STOP=4;
    reg [2:0] state;
    reg [3:0] tick_count; // Counts 0-15 for 16x oversampling
    reg [2:0] bit_index;
    reg parity_bit;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            state <= IDLE;
            tx <= 1;
            tx_done <= 0;
            tx_busy <= 0;
        end else begin
            tx_done <= 0;
            if (tick_16x) begin
                case (state)
                    IDLE: begin
                        tx <= 1;
                        if (tx_start) begin
                            state <= START;
                            tick_count <= 0;
                            tx_busy <= 1;
                            // Calculate parity (Simple XOR)
                            parity_bit <= lcr[1] ? ^din : ~^din; 
                        end
                    end
                    START: begin
                        tx <= 0; // Start bit low
                        if (tick_count == 15) begin
                            state <= DATA;
                            tick_count <= 0;
                            bit_index <= 0;
                        end else tick_count <= tick_count + 1;
                    end
                    DATA: begin
                        tx <= din[bit_index];
                        if (tick_count == 15) begin
                            tick_count <= 0;
                            if (bit_index == 7) begin
                                state <= lcr[0] ? PARITY : STOP;
                            end else bit_index <= bit_index + 1;
                        end else tick_count <= tick_count + 1;
                    end
                    PARITY: begin
                        tx <= parity_bit;
                        if (tick_count == 15) begin
                            state <= STOP;
                            tick_count <= 0;
                        end else tick_count <= tick_count + 1;
                    end
                    STOP: begin
                        tx <= 1; // Stop bit high
                        if (tick_count == 15) begin
                            state <= IDLE;
                            tx_done <= 1;
                            tx_busy <= 0;
                        end else tick_count <= tick_count + 1;
                    end
                endcase
            end
        end
    end
endmodule