/*module testbench();
    logic clk;
    logic [11:0] adc_raw_val; 
    logic [11:0] test_mem [0:4999];
	 logic [1:0] KEY;
	 logic [15:0] ARDUINO_IO;
	 logic [9:0] LEDR;
    int addr = 0;

    

  arrhythmias_detection_toplevel dut (.MAX10_CLK1_50(clk),.KEY(KEY),.ARDUINO_IO(ARDUINO_IO),.LEDR(LEDR));
  
  initial begin
        $readmemh("ecg_data.txt", test_rom);
        clk = 0; rst = 1; #20 rst = 0;
    end

    // 2. Generate Clock (50MHz)
    always #10 clk = ~clk;

    // 3. Feed the data on every ms_tick
    always_ff @(posedge clk) begin
        if (ms_tick && i < 1000) begin
            ecg_in <= test_rom[i];
            i <= i + 1;
        end
    end
endmodule*/