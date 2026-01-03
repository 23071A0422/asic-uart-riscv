module baud_gen(
    input wire clk, rst_n,
    input wire [15:0] divisor,
    output reg tick_16x
);
    reg [15:0] count;
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            count <= 0;
            tick_16x <= 0;
        end else begin
            if (count >= divisor) begin
                count <= 0;
                tick_16x <= 1;
            end else begin
                count <= count + 1'b1;
                tick_16x <= 0;
            end
        end
    end
endmodule