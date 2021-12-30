// Brian Dallaire
// 05/16/2021
// EE 371
// Lab #4, Task 2

// series_dffs takes the 1-bit inputs clk and reset and variable-bit input raw, and outputs the variable-bit output clean.
// The purpose of this module is that it represents two DFFs in series. When a signal goes through two DFFs, it is very 
// difficult for it to reach metastability with other signals. I used a global parameter in this module so that multiple
// bit inputs are possible without having to call this module more than once.

module series_dffs # (parameter BITS = 1) (clk, reset, raw, clean);

	input logic clk, reset;
	input logic [BITS-1 : 0] raw;
	output logic [BITS-1 : 0] clean;
	logic [BITS-1 : 0] n1;
	
	// always_ff block that shows the DFFs displacing the signal. The input signal goes into the first DFF and
	// the output of the first DFF goes in as the input to the second DFF. The output of the second DFF is the
	// output clean
	
	always_ff @(posedge clk) begin
		if(reset) begin
			n1    <= '0;
			clean <= '0;
		end else 
			n1    <= raw; 
			clean <= n1; 
		
	end
	
endmodule 

// series_dffs_testbench tests to see if the flip flops in series works properly even with multiple bit inputs
// I tested to see if different values will bug and output incorrectly

module series_dffs_testbench();
	logic clk, reset;
	logic [4:0] raw;
	logic [4:0] clean;
	
	series_dffs #(.BITS(5)) dut (.clk, .reset, .raw, .clean);
	
	parameter CLOCK_PERIOD=100;
	initial begin
		clk <= 0;
		forever #(CLOCK_PERIOD/2) clk <= ~clk; // Forever toggle the clock
	end
	
	initial begin 
		reset <= 1;						  @(posedge clk);
		reset <= 0; raw <= 5'b00000; @(posedge clk);
						raw <= 5'b11001; @(posedge clk);
						raw <= 5'b10111; @(posedge clk);
								 repeat(4) @(posedge clk);
		
		$stop;
	end
endmodule 

		