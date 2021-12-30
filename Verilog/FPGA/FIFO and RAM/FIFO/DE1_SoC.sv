// Brian Dallaire
// 04/23/2021
// EE 371
// Lab #2, Task 3

// DE1_SoC takes a 1-bit input CLOCK_50, 4-bit input KEY, 10-bit input SW and returns the six, 7-bit outputs
// HEX5-HEX0 and 10-bit output LEDR. DE1_SoC combines all of the modules in Task 3 and uses HEX5-HEX0 to display
// the values of the read and write data and read and write addresses in hexadecimal values. A counter is implemented
// to increment the read address. It also outputs the full and empty signals into LEDR[9] and LEDR[8], respectively.

module DE1_SoC (HEX0, HEX1, HEX2, HEX3, HEX4, HEX5, KEY, SW, LEDR, CLOCK_50);

	output logic [6:0] HEX0, HEX1, HEX2, HEX3, HEX4, HEX5;
	output logic [9:0] LEDR;
	input logic [3:0] KEY;
	input logic [9:0] SW;
	input logic CLOCK_50;
	
	assign HEX3 = 7'b1111111;
	assign HEX2 = 7'b1111111;
	
	logic read, write;
	logic full, empty;
	logic reset;
	logic [7:0] inputBus, outputBus;
	
	assign reset = SW[9];
	assign LEDR[9] = full;
	assign LEDR[8] = empty;
	
	// series_dffs has a 1-bit input CLOCK_50, SW[9], and 8-bit input SW[7:0] and ouptuts the 8-bit output
	// inputBus. This ensures SW[7:0] outputs a clean signal and prevents metastability using two flip-flops in series
	series_dffs #(.BITS(8)) cleanData (.clk(CLOCK_50), .reset(SW[9]), .raw(SW[7:0]), .clean(inputBus));
	
	// input_buffer takes a 1-bit input CLOCK_50, SW[9], and KEY[3] and outputs the 1-bit output read.
	// this ensures that the key press will only result in one clock cycle where read is true.
	input_buffer readBuffer  (.clk(CLOCK_50), .reset, .press(~KEY[3]), .out(read));
	
	// input_buffer takes a 1-bit input CLOCK_50, SW[9], and KEY[2] and outputs the 1-bit output write.
	// this ensures that the key press will only result in one clock cycle where write is true.
	input_buffer writeBuffer (.clk(CLOCK_50), .reset, .press(~KEY[2]), .out(write));
	
	// FIFO takes the 1-bit inputs clk, reset, read, and write and the variable-bit inputBus input and ouputs/
	// the 1-bit outputs empty and full and the variable-bit output outputBus. This module is the core of this
	// task, and represents both the 16x8 RAM and FIFO_Control modules.
	FIFO f (.clk(CLOCK_50), .reset, .read, .write, .inputBus, .empty, .full, .outputBus);
 	
	// seg7hex takes the 4-bit input which is the last 4 bits of inputBus, and outputs
	// the corresponding hexadecimal value to the 7-segment display HEX5
	seg7hex inputBus_L  (.bcd(inputBus[7:4]), .leds(HEX5));
	
	// seg7hex takes the 4-bit input which is the first 4 bits of inputBus, and outputs
	// the corresponding hexadecimal value to the 7-segment display HEX4
	seg7hex inputBus_R  (.bcd(inputBus[3:0]), .leds(HEX4));
	
	// seg7hex takes the 4-bit input which is the last 4 bits of outputBus, and outputs
	// the corresponding hexadecimal value to the 7-segment display HEX1
	seg7hex outputBus_L (.bcd(outputBus[7:4]), .leds(HEX1));
	
	// seg7hex takes the 4-bit input which is the first 4 bits of outputBus, and outputs
	// the corresponding hexadecimal value to the 7-segment display HEX0
	seg7hex outputBus_R (.bcd(outputBus[3:0]), .leds(HEX0));
	
endmodule 

// DE1_SoC_testbench tests the expected and unexpected situations of this task. For this simulation, 
// I tested what happens if I write into a lot of addresses, more than enough to make the FIFO full,
// and tested if when full the FIFO will behave normally. Then, I read all of these values more than
// enough times to see if the FIFO will behave normally when trying to read an empty FIFO.

`timescale 1 ps / 1 ps
module DE1_SoC_testbench();
	logic [6:0] HEX0, HEX1, HEX2, HEX3, HEX4, HEX5;
	logic [9:0] LEDR;
	logic [3:0] KEY;
	logic [9:0] SW;
	logic CLOCK_50;
	
	DE1_SoC dut (.HEX0, .HEX1, .HEX2, .HEX3, .HEX4, .HEX5, .KEY, .SW, .LEDR, .CLOCK_50);
	
	parameter CLOCK_PERIOD = 100;
	initial begin
		CLOCK_50 <= 0;
		forever #(CLOCK_PERIOD/2) CLOCK_50 <= ~CLOCK_50; // Forever toggle the clock
	end
	initial begin
		SW[9] <= 1;																	  @(posedge CLOCK_50);
		SW[9] <= 0; SW[7:0] <= 8'b00000000; KEY[3] <= 1; KEY[2] <= 1; @(posedge CLOCK_50);
						SW[7:0] <= 8'b01101010; 				 KEY[2] <= 0; @(posedge CLOCK_50);
																		 KEY[2] <= 1; @(posedge CLOCK_50);
						SW[7:0] <= 8'b00011001; 				 KEY[2] <= 0; @(posedge CLOCK_50);
																		 KEY[2] <= 1; @(posedge CLOCK_50);
						SW[7:0] <= 8'b00011001; 				 KEY[2] <= 0; @(posedge CLOCK_50);
																		 KEY[2] <= 1; @(posedge CLOCK_50);
						SW[7:0] <= 8'b11000001; 				 KEY[2] <= 0; @(posedge CLOCK_50);
																		 KEY[2] <= 1; @(posedge CLOCK_50);
						SW[7:0] <= 8'b01111001; 				 KEY[2] <= 0; @(posedge CLOCK_50);
																		 KEY[2] <= 1; @(posedge CLOCK_50);
						SW[7:0] <= 8'b01111000; 				 KEY[2] <= 0; @(posedge CLOCK_50);
																		 KEY[2] <= 1; @(posedge CLOCK_50);
						SW[7:0] <= 8'b00010101; 				 KEY[2] <= 0; @(posedge CLOCK_50);
																		 KEY[2] <= 1; @(posedge CLOCK_50);
						SW[7:0] <= 8'b11000001; 				 KEY[2] <= 0; @(posedge CLOCK_50);
																		 KEY[2] <= 1; @(posedge CLOCK_50);
						SW[7:0] <= 8'b01001001; 				 KEY[2] <= 0; @(posedge CLOCK_50);
																		 KEY[2] <= 1; @(posedge CLOCK_50);
						SW[7:0] <= 8'b01000010; 				 KEY[2] <= 0; @(posedge CLOCK_50);
																		 KEY[2] <= 1; @(posedge CLOCK_50);
						SW[7:0] <= 8'b00101011; 				 KEY[2] <= 0; @(posedge CLOCK_50);
																		 KEY[2] <= 1; @(posedge CLOCK_50);
						SW[7:0] <= 8'b10100010; 				 KEY[2] <= 0; @(posedge CLOCK_50);
																		 KEY[2] <= 1; @(posedge CLOCK_50);
						SW[7:0] <= 8'b00110101; 				 KEY[2] <= 0; @(posedge CLOCK_50);
																		 KEY[2] <= 1; @(posedge CLOCK_50);
						SW[7:0] <= 8'b11001001; 				 KEY[2] <= 0; @(posedge CLOCK_50);
																		 KEY[2] <= 1; @(posedge CLOCK_50);
						SW[7:0] <= 8'b11010111; 				 KEY[2] <= 0; @(posedge CLOCK_50);
																		 KEY[2] <= 1; @(posedge CLOCK_50);
						SW[7:0] <= 8'b11100111; 				 KEY[2] <= 0; @(posedge CLOCK_50);
																		 KEY[2] <= 1; @(posedge CLOCK_50);
						SW[7:0] <= 8'b11111001; 				 KEY[2] <= 0; @(posedge CLOCK_50);
																		 KEY[2] <= 1; @(posedge CLOCK_50);
						SW[7:0] <= 8'b11111111;					 KEY[2] <= 0; @(posedge CLOCK_50);
						SW[7:0] <= 8'b00000000;					 KEY[2] <= 1; @(posedge CLOCK_50);
						repeat(18) begin
								KEY[3] <= 0; @(posedge CLOCK_50);
								KEY[3] <= 1; @(posedge CLOCK_50);
						end
		SW[9] <= 1;																	  @(posedge CLOCK_50);											
		SW[9] <= 0;																     @(posedge CLOCK_50);
		
		$stop;
	end
endmodule 
						
