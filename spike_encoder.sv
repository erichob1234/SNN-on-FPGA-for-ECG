module spike_encoder #(
    parameter DATA_WIDTH = 12,
    parameter STEP_SIZE  = 12'd50  // Sensitivity: smaller = more spikes
)(
    input  logic clk,
    input  logic rst,
    input  logic [DATA_WIDTH-1:0] data_in,     // DC-subtracted ECG
    input  logic data_valid,
    output logic spike_up,    // High when signal increases
    output logic spike_down   // High when signal decreases
);

    logic [DATA_WIDTH-1:0] prev_data; //**********DOESNT ENCODE MAGNITUDE OF CHANGE, maybe cahnge later

    always_ff @(posedge clk or negedge rst) begin
        if (!rst) begin
            prev_data  <= '0;
            spike_up   <= 1'b0;
            spike_down <= 1'b0;
        end 
		  else if (data_valid) begin
            // Detect significant positive change
            if (data_in > (prev_data + STEP_SIZE)) begin
                spike_up   <= 1'b1;
                spike_down <= 1'b0;
                prev_data  <= data_in; // Update reference
            end 
            // Detect significant negative change
            else if (data_in < (prev_data - STEP_SIZE)) begin
                spike_up   <= 1'b0;
                spike_down <= 1'b1;
                prev_data  <= data_in; // Update reference
            end 
            else begin
                spike_up   <= 1'b0;
                spike_down <= 1'b0; //use two neurons one for each signal, making feature map
            end
        end 
    end

endmodule