// Brian Dallaire
// 04/23/2021
// EE 371
// Lab #2, Task 3

// DE1_SoC takes a 1-bit input CLOCK_50, 4-bit input KEY, 10-bit input SW and returns the six, 7-bit outputs
// HEX5-HEX0 and 10-bit output LEDR. DE1_SoC combines all of the modules in Task 2 and uses HEX1 and HEX0 to
// display the output address if applicable and LEDR9, LEDR8 if the input value determined by SW7-0 is found
// or not found. The output address is represented in hexadecimal.

module DE1_SoC (HEX0, HEX1, HEX2, HEX3, HEX4, HEX5, KEY, SW, LEDR, CLOCK_50);

	output logic [6:0] HEX0, HEX1, HEX2, HEX3, HEX4, HEX5;
	output logic [9:0] LEDR;
	input logic [3:0] KEY;
	input logic [9:0] SW;
	input logic CLOCK_50;
	
	assign HEX5 = 7'b1111111;
	assign HEX4 = 7'b1111111;
	assign HEX3 = 7'b1111111;
	assign HEX2 = 7'b1111111;
	
	logic start, found, notfound, hide;
	logic [7:0] valueIn;
	logic [4:0] addrOut;
	
	// series_dffs has a 1-bit input CLOCK_50, KEY[0], and 1-bit input SW[9] and ouptuts the 1-bit output
	// start. This ensures SW[7:0] outputs a clean signal and prevents metastability using two flip-flops in series	
	series_dffs #(.BITS(1)) cleanstart (.clk(CLOCK_50), .reset(~KEY[0]), .raw(SW[9]), .clean(start));
	
	// series_dffs has a 1-bit input CLOCK_50, KEY[0], and 8-bit input SW[7:0] and ouptuts the 8-bit output
	// valueIn. This ensures SW[7:0] outputs a clean signal and prevents metastability using two flip-flops in series
	series_dffs #(.BITS(8)) cleanvalue (.clk(CLOCK_50), .reset(~KEY[0]), .raw(SW[7:0]), .clean(valueIn));
	
	// binary_search has the 1-bit inputs clk, reset, and start and 8-bit input valueIn and outputs the 5-bit output
	// addrOut and the 1-bit outputs found, notfound, and hide. The main purpose of this module is to perform the
	// binary search algorithm to find the value of valueIn within the RAM unit. 
	binary_search locate (.clk(CLOCK_50), .reset(~KEY[0]), .start, .valueIn, .addrOut, .found, .notfound, .hide);
	
	// seg7hex takes the 4-bit input which is the first 4 bits of addrOut and the 1-bit input hide and outputs
	// the corresponding hexadecimal value to the 7-segment display HEX0. Hide determines if the display is 
	// on or off.
	seg7hex firstdig (.bcd(addrOut[3:0]), .hide, .leds(HEX0));
	
	// seg7hex takes the 4-bit input which is the first 4 bits of addrOut and the 1-bit input hide and outputs
	// the corresponding hexadecimal value to the 7-segment display HEX0. Hide determines if the display is 
	// on or off.
	seg7hex secondig (.bcd({3'b000, addrOut[4]}), .hide, .leds(HEX1));
	
	assign LEDR[9] = found;
	assign LEDR[8] = notfound;
	
endmodule 

// DE1_SoC_testbench tests the expected and unexpected situations of this task. For this simulation, 
// I tested what happens if I input values outside the RAM from both directions. I also tested values
// that were both above the initial starting address and below. This way, I can see that the task works
// properly in all cases.

`timescale 1 ps / 1 ps
module DE1_SoC_testbench();

	logic [6:0] HEX0, HEX1, HEX2, HEX3, HEX4, HEX5;
	logic [9:0] LEDR;
	logic [3:0] KEY;
	logic [9:0] SW;
	logic CLOCK_50;
	
	DE1_SoC dut (.HEX0, .HEX1, .HEX2, .HEX3, .HEX4, .HEX5, .KEY, .SW, .LEDR, .	CLOCK_50);

	parameter CLOCK_PERIOD = 100;
	initial begin 
		CLOCK_50 <= 0;
		forever # (CLOCK_PERIOD/2) CLOCK_50 <= ~CLOCK_50; //Forever toggle clock
	end 
	
	initial begin 
	
		KEY[0] <= 0;																@(posedge CLOCK_50);
		KEY[0] <= 1; SW[9] <= 0; SW[7:0] <= 8'b00000000; repeat(2)  @(posedge CLOCK_50);
						 SW[9] <= 1;								 repeat(10) @(posedge CLOCK_50);
						 SW[9] <= 0; SW[7:0] <= 8'b00100001; repeat(2)  @(posedge CLOCK_50);
						 SW[9] <= 1; 								 repeat(10) @(posedge CLOCK_50);
						 SW[9] <= 0; SW[7:0] <= 8'b00011001; repeat(2)  @(posedge CLOCK_50);
						 SW[9] <= 1; 								 repeat(10) @(posedge CLOCK_50);	
						 SW[9] <= 0; SW[7:0] <= 8'b00000101; repeat(2)  @(posedge CLOCK_50);
						 SW[9] <= 1; 								 repeat(10) @(posedge CLOCK_50);						 
						 
	$stop;
	end
endmodule 
	