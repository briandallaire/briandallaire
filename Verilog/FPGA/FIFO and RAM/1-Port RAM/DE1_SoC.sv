// Brian Dallaire
// 04/23/2021
// EE 371
// Lab #2, Task 1

// DE1_SoC takes a 1-bit input CLOCK_50, 4-bit input KEY, 10-bit input SW and returns the six, 7-bit outputs
// HEX5-HEX0. DE1_SoC combines all of the modules in Task 1 and uses HEX5, HEX4, HEX1, and HEX0 to display the
// values of the input and output data as well as the address. 

module DE1_SoC (HEX0, HEX1, HEX2, HEX3, HEX4, HEX5, KEY, SW, CLOCK_50);
	output logic [6:0] HEX0, HEX1, HEX2, HEX3, HEX4, HEX5;
	input logic [3:0] KEY;
	input logic [9:0] SW;
	input logic CLOCK_50;
	
	assign HEX3 = 7'b1111111;
	assign HEX1 = 7'b1111111;
	
	logic write;
	logic [3:0] dataIn;
	logic [4:0] address;
	logic [3:0] dataOut; 
	
	logic clkSelect;
	//assign clkSelect = ~KEY[0]; // for on-board simulation
	assign clkSelect = CLOCK_50; // for testbench
	
	logic reset;
	assign reset = ~KEY[3]; // reset key added only for the dffs
	
	// series_dffs has a 1-bit input clkSelect, reset, and SW[9] and ouptuts the 1-bit output
	// write. This ensures SW[9] outputs a clean signal and prevents metastability using
	// two flip-flops in series
	
	series_dffs #(.BITS(1)) cleanWrite (.clk(clkSelect), .reset, .raw(SW[9]), .clean(write));
	
	// series_dffs has a 1-bit input clkSelect, reset, and 4-bit input SW[3:0] and ouptuts the 4-bit output
	// dataIn. This ensures SW[3:0] outputs a clean signal and prevents metastability using
	// two flip-flops in series
	
	series_dffs #(.BITS(4)) cleanData  (.clk(clkSelect), .reset, .raw(SW[3:0]), .clean(dataIn));
	
	// series_dffs has a 1-bit input clkSelect, reset, and 5-bit input SW[8:4] and ouptuts the 5-bit output
	// address. This ensures SW[8:4] outputs a clean signal and prevents metastability using
	// two flip-flops in series
	
	series_dffs #(.BITS(5)) cleanAddr  (.clk(clkSelect), .reset, .raw(SW[8:4]), .clean(address));
	
	// RAM32_4 has a 1-bit input clkSelect and write and 4-bit input dataIn and 5-bit input address and
	// outputs a 4-bit output dataOut
	
	RAM32_4 				ram 	  (.clk(clkSelect), .write, .dataIn, .address, .dataOut);
	
	// displayOrganizer takes the 4-bit inputs dataIn and dataOut and the 5-bit input address and
	// outputs 4, 7-bit outputs from HEX5, HEX4, HEX2, and HEX0. This organizes the displays so
	// that the respective HEX displays display the values of dataIn, dataOut, and address in
	// hexadecimal values.
	displayOrganizer displays (.dataIn, .address, .dataOut, .hexArray({HEX5, HEX4, HEX2, HEX0}));
	
endmodule 

// DE1_SoC_testbench tests all of the expected and unexpected behavior of the single-port RAM unit
// In this simulation, I wrote into many address values, and read from those addresses. Then, I rewrote
// in a few of those addresses to test if it can be rewritten. Then, I read addresses that I did not write
// anything in

module DE1_SoC_testbench();

	logic [6:0] HEX0, HEX1, HEX2, HEX3, HEX4, HEX5;
	logic [3:0] KEY;
	logic [9:0] SW;
	logic CLOCK_50;
	
	DE1_SoC dut (.HEX0, .HEX1, .HEX2, .HEX3, .HEX4, .HEX5, .KEY, .SW, .CLOCK_50);
	
	parameter CLOCK_PERIOD=100;
	initial begin
		CLOCK_50 <= 0;
		forever #(CLOCK_PERIOD/2) CLOCK_50 <= ~CLOCK_50; // Forever toggle the clock
	end
	initial begin
		SW[8:4] <= 5'b00000; 				@(posedge CLOCK_50);
		SW[9] <= 1; SW[3:0] <= 4'b0001;  @(posedge CLOCK_50);
		SW[9] <= 0;				  repeat(2) @(posedge CLOCK_50);
		SW[8:4] <= 5'b01001;				   @(posedge CLOCK_50);
		SW[9] <= 1; SW[3:0] <= 4'b1111;  @(posedge CLOCK_50);
		SW[9] <= 0;				  repeat(2) @(posedge CLOCK_50);
		SW[8:4] <= 5'b00000;   repeat(3) @(posedge CLOCK_50);
		
		$stop;
	end
endmodule 