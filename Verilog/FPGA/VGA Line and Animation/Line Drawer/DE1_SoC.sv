// Brian Dallaire
// 05/07/2021
// EE 371
// Lab 3 Task 1

// DE1_SoC takes the 1-bit input CLOCK_50, 4-bit input KEY, 10-bit input SW, and outputs
// 6, 7-bit outputs HEX0, HEX1, HEX2, HEX3, HEX4, HEX5, 10-bit output LEDR, 8-bit outputs
// VGA_R, VGA_G, VGA_B, outputs VGA_BLANK_N, VGA_CLK, VGA_HS, VGA_SYNC_N, and VGA_VS. The 
// main purpose of this module is to instantiate all of the modules in this project and 
// connect them together to output the desired outputs onto the FGPA. DE1_SoC for task 1
// connects line_drawer to VGA_framebuffer to draw lines onto the VGA display using the
// given coordinates for x0, y0, x1, and y1.  

module DE1_SoC (HEX0, HEX1, HEX2, HEX3, HEX4, HEX5, KEY, LEDR, SW, CLOCK_50, 
	VGA_R, VGA_G, VGA_B, VGA_BLANK_N, VGA_CLK, VGA_HS, VGA_SYNC_N, VGA_VS);
	
	output logic [6:0] HEX0, HEX1, HEX2, HEX3, HEX4, HEX5;
	output logic [9:0] LEDR;
	input logic [3:0] KEY;
	input logic [9:0] SW;

	input CLOCK_50;
	output [7:0] VGA_R;
	output [7:0] VGA_G;
	output [7:0] VGA_B;
	output VGA_BLANK_N;
	output VGA_CLK;
	output VGA_HS;
	output VGA_SYNC_N;
	output VGA_VS;
	
	assign HEX0 = '1;
	assign HEX1 = '1;
	assign HEX2 = '1;
	assign HEX3 = '1;
	assign HEX4 = '1;
	assign HEX5 = '1;
	assign LEDR = SW;
	
	logic [10:0] x0, x1, x;
	logic [10:0] y0, y1, y;
	logic frame_start;
	logic pixel_color;
	
	
	//////// DOUBLE_FRAME_BUFFER ////////
	logic dfb_en;
	assign dfb_en = 1'b0;
	/////////////////////////////////////
	
	// VGA_framebuffer takes the 1-bit inputs clk, rst, pixel_color, pixel_write, and dfb_en and
	// the 10-bit inputs x and y and outputs the 1-bit output frame_start, 8-bit outputs VGA_R,
	// VGA_G, and VGA_B, and outputs the 1-bit outputs VGA_CLK, VGA_HS, VGA_VS, VGA_BLANK_N, and
	// VGA_SYNC_N. The main purpose of this module is to provide the timing and double_buffering
	// to the VGA port. For this lab and task 1, this module is used to provide I/O timing and
	// displaying the line onto the VGA display. The double buffering is not enabled in this lab.
	VGA_framebuffer fb(.clk(CLOCK_50), .rst(1'b0), .x, .y,
				.pixel_color, .pixel_write(1'b1), .dfb_en, .frame_start,
				.VGA_R, .VGA_G, .VGA_B, .VGA_CLK, .VGA_HS, .VGA_VS,
				.VGA_BLANK_N, .VGA_SYNC_N);
	
	// line_drawer takes the 1-bit inputs clk and reset and the 11-bit inputs x0, y0, x1, and y1
	// and outputs the 11-bit outputs x and y. The main purpose of this module is to draw a line
   //	between (x0, y0) and (x1, y1). To do this, the outputs x and y determine what pixel will be
	// drawn and line_drawer will output a different x and y pair many times to draw the line
	// one-pixel at a time. The outputs x and y for this module are just values, and the drawing
	// part is done through VGA_framebuffer
	line_drawer lines (.clk(CLOCK_50), .reset(SW[9]),
				.x0, .y0, .x1, .y1, .x, .y);
	
	// draw a line using this coordinates
	assign x0 = 40;
	assign y0 = 40;
	assign x1 = 70;
	assign y1 = 50;
	
	//assign pixel_color = 1'b1; // for testbench, comment out 3 lines below
	initial pixel_color = 1'b0;
	
	// this always_ff block is combined with the initial statement and is used to change the color
	// of the pixel from black to white after a reset. This is to prevent any unwanted lines to be
	// drawn in white before a reset is done
	always_ff @(posedge CLOCK_50) begin
		if (SW[9]) pixel_color <= 1'b1;
	end
endmodule

// DE1_SoC_testbench tests the expected and unexpected cases for this module. For this test bench,
// the assigned values for x0, y0, x1, and y1 need to be manually changed from the DE1_SoC code. 
// thus, I simply reset once and let the clock cyles run until the desired output is there. 

module DE1_SoC_testbench();

   logic [6:0] HEX0, HEX1, HEX2, HEX3, HEX4, HEX5;
	logic [9:0] LEDR;
	logic [3:0] KEY;
	logic [9:0] SW;

	logic CLOCK_50;
	logic [7:0] VGA_R;
	logic [7:0] VGA_G;
	logic [7:0] VGA_B;
	logic VGA_BLANK_N;
	logic VGA_CLK;
	logic VGA_HS;
	logic VGA_SYNC_N;
	logic VGA_VS;
	
	DE1_SoC dut (.HEX0, .HEX1, .HEX2, .HEX3, .HEX4, .HEX5, .KEY, .LEDR, .SW, .CLOCK_50, 
	.VGA_R, .VGA_G, .VGA_B, .VGA_BLANK_N, .VGA_CLK, .VGA_HS, .VGA_SYNC_N, .VGA_VS);

	parameter clock_period = 100;
	
	initial begin
		CLOCK_50 <= 0;
		forever #(clock_period /2) CLOCK_50 <= ~CLOCK_50;
	end
	
	initial begin
		SW[9] <= 1; @(posedge CLOCK_50);
		SW[9] <= 0; repeat(100) @(posedge CLOCK_50);
		$stop;
	end
endmodule 	