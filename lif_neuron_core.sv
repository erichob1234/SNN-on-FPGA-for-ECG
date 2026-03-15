module lif_neuron_core #(
    logic [15:0] BASELINE_TH = 16'h3000, // Starting threshold
    logic [15:0] FATIGUE = 16'h0800, // Increase per fire
    int LEAK  = 6,      // 1/64 leak rate
    int L_SHIFT = 4,       // STDP learning rate
	 INPUTS = 5
	 
)(
    input  logic clock,
    input  logic reset_n,      // Active low reset
    input  logic ms_tick,      // 1ms pulse for timing logic
    input  logic [INPUTS-1:0] spike_in,     
    input  logic inhibit_in,   // Signal from neighbors to reset
    output logic fire_out      
);
//****************MAKE IT SO NEURONS STOP FIRING ONCE IT LEARNS THE NORMAL PATTERNS
    
    logic signed [15:0] vmem;
    logic [15:0] vthreshold;
    logic [15:0] weight [INPUTS-1:0]; //each input wir should have weight register
    
    logic [4:0]  refractory_count; // time in which neuron can not fire agian
    logic [6:0]  tsls_pre [INPUTS-1:0];       // time since last input spike, use register array, to keep time for all input spikes
    logic [6:0]  tsls_post;      // time since last output spike
	 logic [17:0] spike_sum;
	 
    // A fire event only happens if not in cooldown
    assign fire_out = (vmem >= vthreshold) && (refractory_count == 0);

    always_ff @(posedge clock or negedge reset_n) begin
        if (!reset_n) begin
            vmem <= 16'sh0;
            vthreshold <= BASELINE_TH;
            for (int i = 0; i < INPUTS; i++) begin
					weight[i] <= 16'h1000; //***TUNE THIS
				end
            refractory_count <= 5'd0;
				for (int i = 0; i < INPUTS; i++) begin
					tsls_pre[i] <= 7'd127; //initialize these as a lot because stdp only happens a small values 
				end
            tsls_post <= 7'd127;
        end 
		  else begin

            //following executes every ms
            if (ms_tick) begin
                // Increment STDP timers (Saturate at 127 to avoid wrap-around)
                if (tsls_post < 7'd127) tsls_post <= tsls_post + 7'd1;
					 for (int i = 0; i<INPUTS; i++) begin //parallel computation of time
						if (tsls_pre[i]  < 7'd127) begin
							tsls_pre[i]  <= tsls_pre[i]  + 7'd1;
						end
					 end

                // Handle Refractory Cooldown, neruone is shut down
                if (refractory_count > 5'd0) begin
                    refractory_count <= refractory_count - 5'd1;
                    vmem <= 16'sh0; // Clamp to 0 during cooldown
                end 
					 // lateral inhibition
						// If a neighbor fires this neuron is forced to reset
					else if (inhibit_in) vmem <= 16'sh0;
					
					 
					 else begin //neuron is active
						//shift instead of multiplication to conserve hardware
                    vmem <= vmem - (vmem >>> LEAK) + spike_sum; //intgration approximation
                    
                    // Threshold slowly returns to baseline
                    if (vthreshold > BASELINE_TH) begin
							vthreshold <= vthreshold - ((vthreshold - BASELINE_TH) >> 7);
							end
						  
						   // add weight if spike
							for (int i = 0; i<INPUTS; i++) begin
								if (spike_in[i] && refractory_count == 5'd0) begin
									 tsls_pre[i] <= 7'd0; // Reset input timer

									 if (tsls_post < 7'd32) begin
										  // Shift factor increases as time gap increases (simulating exp decay)
										  weight[i] <= weight[i] - (weight[i] >> (L_SHIFT + (tsls_post >> 2)));
									 end
								end
							end
						  //neuron fires
							if (fire_out) begin
								 vmem           <= 16'sh0;            // Reset potential
								 vthreshold     <= vthreshold + FATIGUE; // Apply fatigue
								 refractory_count <= 5'd20;            // Start 20ms cooldown
								 tsls_post      <= 7'd0;              // Reset output timer

								 // STDP LTP (Causal)
								 for (int i = 0; i<INPUTS; i++) begin
									 if(tsls_pre[i] < 7'd32) begin
										 weight[i] <= weight[i] + ((16'hFFFF - weight[i]) >> (L_SHIFT + (tsls_pre[i] >> 2)));
									 end
								end
							end
					end
            end
			end
            

    end
	 
	 always_comb begin
		spike_sum = 18'd0;
		for (int i = 0; i<INPUTS; i++) begin
			if(spike_in[i]) begin
				spike_sum = spike_sum + weight[i];
			end
		end
	 end
endmodule