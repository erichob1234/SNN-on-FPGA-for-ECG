module spike_encoder #(
    parameter DATA_WIDTH = 12, // Removed the '12' from the name, keep it generic
	 STEP_SIZE  = 12'd50,  // Sensitivity: smaller = more
    parameter signed [DATA_WIDTH-1:0] PWAVE = 12'sd10, // 'sd' for Signed Decimal
    parameter signed [DATA_WIDTH-1:0] RPEAK = 12'sd50,
    parameter signed [DATA_WIDTH-1:0] TWAVE = -12'sd10,
    parameter signed [DATA_WIDTH-1:0] SWAVE = -12'sd50,
	 FLATLINE =0
)(
    input  logic clk,
    input  logic rst,
    input  logic signed [DATA_WIDTH-1:0] data_in, // Added signed here
    input  logic data_valid,
    input  logic ms_tick,
    output logic [4:0] spike_bus
);

    logic [DATA_WIDTH-1:0] previousdata;
	 logic signed [DATA_WIDTH:0] delta;
	 
	 //calculate rate of change
	 always_ff @(posedge clk or negedge rst) begin
		if(!rst) begin
			delta<=0;
			previousdata<=0;
			end
		else if(ms_tick) begin
			delta <= $signed({1'b0, data_in}) - $signed({1'b0, previousdata}); //use twos complement 
			previousdata<=data_in;
			
			//feature map
        if (ms_tick) begin
            spike_bus[0] <= (delta > PWAVE && delta <= RPEAK); 
            spike_bus[1] <= (delta > RPEAK);                          
            spike_bus[2] <= (delta < SWAVE);                         
            spike_bus[3] <= (delta < TWAVE && delta >= SWAVE); 
            spike_bus[4] <= (data_in == FLATLINE);                      
        end
		end
	 end
		  

endmodule