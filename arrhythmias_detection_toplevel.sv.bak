module top_level();

endmodule

module clock_prescaler #(parameter CLK_FREQ = 50_000_000, parameter TARGET_MS = 1)(
																												 input  logic clk,
																												 input  logic rst_n,
																												 output logic ms_tick  // High for 1 clock cycle every 1ms
																											);

    // 50,000,000 / 1000 = 50,000 cycles for 1ms
    // 16 bits handles up to 65,535
    logic [15:0] counter;

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            counter <= 16'd0;
            ms_tick <= 1'b0;
        end else if (counter >= (CLK_FREQ/1000 - 1)) begin
            counter <= 16'd0;
            ms_tick <= 1'b1;
        end else begin
            counter <= counter + 16'd1;
            ms_tick <= 1'b0;
        end
    end

endmodule