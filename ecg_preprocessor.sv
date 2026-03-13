module ecgpreprocessor (
    input  logic clk,
    input  logic rst,

    input  logic [11:0] adc_data,
    input  logic [4:0]  adc_channel,
    input  logic        adc_valid,

    output logic signed [12:0] processed_data,
    output logic out_valid
);

localparam DATA_WIDTH = 12;

logic [15:0] sum;
logic [11:0] baseline;

	always_ff @(posedge clk or negedge rst) begin
		 if (!rst) begin
			  sum <= 0;
			  baseline <= 0;
			  processed_data <= 0;
			  out_valid <= 0;
		 end

		 else if (adc_valid && adc_channel == 5'd1) begin

			  // moving average baseline approximation(to save on hardware), ***FIX THIS SHIT IS SO SCUFFED
			  sum <= sum + adc_data - baseline;
			  baseline <= sum >> 4;

			  // high-pass filter
			  processed_data <= $signed(adc_data) - $signed(baseline);

			  out_valid <= 1'b1;
		 end

		 else begin
			  out_valid <= 1'b0;
		 end
	end

endmodule