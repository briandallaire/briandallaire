// Brian Dallaire
// 04/23/2021
// EE 371
// Lab #2, Task 2

// DE1_SoC takes a 1-bit input CLOCK_50, 4-bit input KEY, 10-bit input SW and returns the six, 7-bit outputs
// HEX5-HEX0. DE1_SoC combines all of the modules in Task 2 and uses HEX5-HEX0 to display the values of the
// read and write data and read and write addresses in hexadecimal values. A counter is implemented to increment
// the read address.


module DE1_SoC (HEX0, HEX1, HEX2, HEX3, HEX4, HEX5, KEY, SW, CLOCK_50);

	output logic [6:0] HEX0, HEX1, HEX2, HEX3, HEX4, HEX5;
	input logic [3:0] KEY;
	input logic [9:0] SW;
	input logic CLOCK_50;
	
	logic [31:0] div_clk;
	// clock_divider takes the 1-bit inputs clk and reset and outputs the 32 bit output
	// div_clk. The purpose of this module is to slow down CLOCK_50 for on-board demonstration.
	// Using the value div_clk[25] will make the clock 0.75 Hz instead of 50MHz like CLOCK_50
	clock_divider cdiv (.clk(CLOCK_50),
	                    .reset(~KEY[0]),
							  .divided_clocks(div_clk));
							
	logic clkSelect; // for easy switching between clocks
	assign clkSelect = CLOCK_50; // for simulation
	//assign clkSelect = div_clk[25]; // for board
	
	logic [4:0] rdaddress;
	logic [3:0] rdData;	
	logic [4:0] writeAddr;
	logic [3:0] dataIn;
	logic wren;
	
	// series_dffs has a 1-bit input CLOCK_50, KEY[0], and 5-bit input SW[8:4] and ouptuts the 5-bit output
	// writeAddr. This ensures SW[8:4] outputs a clean signal and prevents metastability using two flip-flops in series
	series_dffs #(.BITS(5)) cleanAddr (.clk(CLOCK_50), .reset(~KEY[0]), .raw(SW[8:4]), .clean(writeAddr));
	
	// series_dffs has a 1-bit input CLOCK_50, KEY[0], and 4-bit input SW[3:0] and ouptuts the 4-bit output
	// dataIn. This ensures SW[3:0] outputs a clean signal and prevents metastability using
	// two flip-flops in series
	series_dffs #(.BITS(4)) cleanData (.clk(CLOCK_50), .reset(~KEY[0]), .raw(SW[3:0]), .clean(dataIn));
	
	// series_dffs has a 1-bit input CLOCK_50, KEY[0], and KEY[3] and ouptuts the 1-bit output
	// wren. This ensures SW[9] outputs a clean signal and prevents metastability using two flip-flops in series
	series_dffs #(.BITS(1)) cleanwren (.clk(CLOCK_50), .reset(~KEY[0]), .raw(~KEY[3]), .clean(wren));

	
	// counter uses the 1-bit inputs clkSelect and KEY[0] and outputs the 5-bit output rdaddress.
	// the purpose of this module is to increment the read address
	counter 			  readAddr (.clk(clkSelect), .reset(~KEY[0]), .out(rdaddress));
	
	// ram32x4 is a verilog file that uses 1-bit input CLOCK_50, 4-bit input dataIn, 5-bit inputs rdaddress and wraddress,
	// and 1-bit input wren to output the 4-bit output rdData. The purpose of this module is that it is the 32x4 dual-port
	// RAM that the IP catalog generated and is the core of this task
	ram32x4 			  ram		  (.clock(CLOCK_50), .data(dataIn), .rdaddress, .wraddress(SW[8:4]), .wren, .q(rdData));
	
	// displayOrganizer takes the 4-bit inputs rdData and wrdata, and the 5-bit inputs rdaddress and wraddress and outputs
	// 6, 7-bit outputs HEX5-HEX0. The purpose of this module is to organize the displays so that the inputs will be displayed
	// in their respective HEX displays and the proper hexadecimal values will be displayed
	displayOrganizer displays (.rdData, .rdaddress, .wrdata(dataIn), .wraddress(SW[8:4]), .hexArray({HEX5, HEX4, HEX3, HEX2, HEX1, HEX0}));

endmodule 

// DE1_SoC_testbench tests the expected and unexpected situations for this task. In this simulation, 
// I tested to see if I write nothing the MIF values will be read properly, then I rewrote values into
// some of the addresses to see if their values can be overwritten

`timescale 1 ps / 1 ps
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
											repeat(1) @(posedge CLOCK_50);
		KEY[0] <= 0; 					repeat(1) @(posedge CLOCK_50);
		KEY[0] <= 1;					repeat(32) @(posedge CLOCK_50);
		KEY[3] <= 0;SW[8:4] <= 5'b00001; SW[3:0] <= 4'b0001; repeat(1) @(posedge CLOCK_50);
		KEY[3] <= 1;					repeat(1) @(posedge CLOCK_50);
		KEY[3] <= 0; SW[8:4] <= 5'b00100; SW[3:0] <= 4'b1111; repeat(1) @(posedge CLOCK_50);
		KEY[3] <= 1;					repeat(1) @(posedge CLOCK_50);
											repeat(4) @(posedge CLOCK_50);

		
		$stop;
	end
	
endmodule 