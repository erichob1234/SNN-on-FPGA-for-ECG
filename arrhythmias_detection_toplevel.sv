module arrhythmias_detection_toplevel(input logic MAX10_CLK1_50,
													input logic [1:0] KEY,
													inout wire [11:0] ARDUINO_IO, 
													output logic [9:0] LEDR);
													

logic clk;
logic rst;
logic [4:0] spikebus;
logic [4:0] firstlayerbus;
logic [7:0] secondlayerbus;
logic [1:0] outputbus;
logic [11:0] data_in;
logic inhibit1;
logic inhibit2;
logic inhibit3;
logic data_valid;
assign rst = KEY[0];
assign clk = MAX10_CLK1_50;
assign LEDR[1:0] = outputbus;
assign data_in = ARDUINO_IO;
							
//input bus from spike encoder
spike_encoder #( .DATA_WIDTH(12), 
					 .STEP_SIZE(12'd50),
					 .PWAVE(12'd10),
					 .RPEAK(12'd50),
					 .TWAVE(-12'd10),
					 .SWAVE(-12'd50),
					 .FLATLINE(12'd0)) 
encoder_instance1 (.clk(clk),
					 .rst(rst),
					 .data_in(data_in),       
					 .data_valid(data_valid),
					 .ms_tick(ms_tick),        
					 .spike_bus(spikebus));

//feed to layer 1
						
genvar i;
generate
    for (i = 0; i < 5; i++) begin : firslayer
        lif_neuron_core #(.BASELINE_TH(16'h3000),
						.FATIGUE(16'h0800),
						.LEAK(6),
						.L_SHIFT(4),
						.INPUTS(5))
				l1n1(.clock(clk),
						.reset_n(rst),
						.ms_tick(ms_tick),
						.spike_in(spikebus),
						.inhibit_in(inhibit1),
						.fire_out(firstlayerbus[i]));
    end
endgenerate

//feed layer 2 
generate
    for (i = 0; i < 8; i++) begin : hiddenlayer
        lif_neuron_core #(.BASELINE_TH(16'h3000),
						.FATIGUE(16'h0800),
						.LEAK(6),
						.L_SHIFT(4),
						.INPUTS(5))
				l1n1(.clock(clk),
						.reset_n(rst),
						.ms_tick(ms_tick),
						.spike_in(firstlayerbus),
						.inhibit_in(inhibit2),
						.fire_out(secondlayerbus[i]));
    end
endgenerate

//output layer
generate
    for (i = 0; i < 2; i++) begin : outputlayer
        lif_neuron_core #(.BASELINE_TH(16'h3000),
						.FATIGUE(16'h0800),
						.LEAK(6),
						.L_SHIFT(4),
						.INPUTS(8))
				l1n1(.clock(clk),
						.reset_n(rst),
						.ms_tick(ms_tick),
						.spike_in(secondlayerbus),
						.inhibit_in(inhibit3),
						.fire_out(outputbus[i]));
    end
endgenerate

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

