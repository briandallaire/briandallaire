// Brian Dallaire
// 04/14/2021
// EE 371
// Lab #1, Task 4

// series_dffs has 1-bit inputs clk, reset, and raw. It outputs a 1-bit output clean. The purpose of this module
// is that it represents two DFFs in series. When a signal goes through two DFFs, it is very difficult for 
// it to reach metastability with other signals.

module series_dffs(clk, reset, raw, clean);

	input logic clk, reset, raw;
	output logic clean;
	logic n1;
	
	// always_ff block that shows the DFFs displacing the signal. The 1-bit input signal goes into the first DFF and
	// the output of the first DFF goes in as the input to the second DFF. The output of the second DFF is the 1-bit
	// output clean
	always_ff @(posedge clk) begin
		if(reset) begin
			n1    <= 0;
			clean <= 0;
		end else 
			n1    <= raw; 
			clean <= n1; 
		
	end
	
endmodule 