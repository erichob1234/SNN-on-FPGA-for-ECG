module lif_neuron_core #(
    parameter logic [15:0] BASELINE_TH = 16'h3000, // Starting threshold
    parameter logic [15:0] FATIGUE = 16'h0800, // Increase per fire
    parameter int          LEAK  = 6,      // 1/64 leak rate
    parameter int          L_SHIFT     = 4       // STDP learning rate
)(
    input  logic        clock,
    input  logic        reset_n,      // Active low reset
    input  logic        ms_tick,      // 1ms pulse for timing logic
    input  logic        spike_in,     
    input  logic        inhibit_in,   // Signal from neighbors to reset
    output logic        fire_out      
);
//****************MAKE IT SO NEURONS STOP FIRING ONCE IT LEARNS THE NORMAL PATTERNS
    
    logic signed [15:0] vmem;
    logic [15:0]        vthreshold;
    logic [15:0]        weight;
    
    logic [4:0]  refractory_count; // 20ms cooldown timer
    logic [6:0]  tsls_pre;       // time since last input spike
    logic [6:0]  tsls_post;      // time since last output spike
	 
    // A fire event only happens if not in cooldown
    assign fire_out = (vmem >= vthreshold) && (refractory_count == 0);

    always_ff @(posedge clock or negedge reset_n) begin
        if (!reset_n) begin
            vmem           <= 16'sh0;
            vthreshold     <= BASELINE_TH;
            weight         <= 16'h1000; // Initial "trust" value
            refractory_count <= 5'd0;
            tsls_pre       <= 7'd127; //initialize these as a lot because stdp only happens a small values
            tsls_post      <= 7'd127;
        end 
		  else begin

            //following executes every ms
            if (ms_tick) begin
                // Increment STDP timers (Saturate at 127 to avoid wrap-around)
                if (tsls_pre  < 7'd127) tsls_pre  <= tsls_pre  + 7'd1;
                if (tsls_post < 7'd127) tsls_post <= tsls_post + 7'd1;

                // Handle Refractory Cooldown
                if (refractory_count > 5'd0) begin
                    refractory_count <= refractory_count - 5'd1;
                    vmem <= 16'sh0; // Clamp to 0 during cooldown
                end else begin
						//shift instead of multiplication to conserve hardware
                    vmem <= vmem - (vmem >>> LEAK);
                    
                    // Threshold slowly returns to baseline
                    if (vthreshold > BASELINE_TH)
                        vthreshold <= vthreshold - ((vthreshold - BASELINE_TH) >> 7);
                end
            end

            // lateral inhibition
            // If a neighbor fires this neuron is forced to reset
            if (inhibit_in) begin
                vmem <= 16'sh0;
            end

            // add weight if spike
            if (spike_in && refractory_count == 5'd0) begin
                tsls_pre <= 7'd0; // Reset input timer
                vmem     <= vmem + weight;

           
                if (tsls_post < 7'd32) begin
                    // Shift factor increases as time gap increases (simulating exp decay)
                    weight <= weight - (weight >> (L_SHIFT + (tsls_post >> 2)));
                end
            end

            //neuron fires
            if (fire_out) begin
                vmem           <= 16'sh0;            // Reset potential
                vthreshold     <= vthreshold + FATIGUE; // Apply fatigue
                refractory_count <= 5'd20;            // Start 20ms cooldown
                tsls_post      <= 7'd0;              // Reset output timer

                // STDP LTP (Causal)
                if (tsls_pre < 7'd32) begin
                   weight <= weight + ((16'hFFFF - weight) >> (L_SHIFT + (tsls_pre >> 2)));
                end
            end
        end
    end
endmodule