module uart_rx(
    input wire clk, rst_n,
    input wire tick_16x,
    input wire rx,
    input wire [2:0] lcr, // {parity_en, parity_type, stop_bits}
    output reg [7:0] dout,
    output reg rx_done,
    output reg frame_err,
    output reg parity_err
);
    localparam IDLE=0, START=1, DATA=2, PARITY=3, STOP=4;
    reg [2:0] state;
    reg [3:0] tick_count;
    reg [2:0] bit_index;
    reg [1:0] rx_sync;

    // Sync RX input
    always @(posedge clk or negedge rst_n) begin
    if (!rst_n)
        rx_sync <= 2'b11;   // UART idle state
    else
        rx_sync <= {rx_sync[0], rx};
end

    wire rx_in = rx_sync[1];

    always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        state <= IDLE;
        rx_done <= 0;
        frame_err <= 0;
        parity_err <= 0;
        tick_count <= 0;
    end else begin
        rx_done <= 0;
        if (tick_16x) begin
            case (state)
                IDLE: begin
                    if (rx_in == 0) begin
                        state <= START;
                        tick_count <= 0;
                    end
                end

                START: begin
                    tick_count <= tick_count + 1;
                    if (tick_count == 7) begin
                        if (rx_in != 0) state <= IDLE;
                    end
                    if (tick_count == 15) begin
                        state <= DATA;
                        tick_count <= 0;
                        bit_index <= 0;
                        dout <= 0;
                    end
                end

                DATA: begin
                    tick_count <= tick_count + 1;
                    if (tick_count == 7)
                        dout[bit_index] <= rx_in;
                    if (tick_count == 15) begin
                        tick_count <= 0;
                        if (bit_index == 7)
                            state <= lcr[0] ? PARITY : STOP;
                        else
                            bit_index <= bit_index + 1;
                    end
                end

                PARITY: begin
                    tick_count <= tick_count + 1;
                    if (tick_count == 7)
                        if (rx_in != (lcr[1] ? ^dout : ~^dout))
                            parity_err <= 1;
                    if (tick_count == 15) begin
                        tick_count <= 0;
                        state <= STOP;
                    end
                end

                STOP: begin
                    tick_count <= tick_count + 1;
                    if (tick_count == 7 && rx_in != 1)
                        frame_err <= 1;
                    if (tick_count == 15) begin
                        rx_done <= 1;
                        state <= IDLE;
                    end
                end
            endcase
        end
    end
end
endmodule