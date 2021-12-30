// Brian Dellaire, Erik Michel
// EE 371
// Lab 6, Design Project

// DE1_SoC takes a 4-bit signal KEY for using KEYs on FPGA board, 10-bit SW signal
// for use of switches on FPGA board, a 1-bit CLOCK_50 signal, a 1-bit N8_DATA_IN signal. DE1_SoC returns
// 8-bit VGA_R, VGA_G, VGA_B, 5 7-bit HEX0-5 signals, 10-bit LEDR signal, 1-bit N8_LATCH signal, 1-bit
// N8_PULSE, VGA_BLANK_N, VGA_CLK, VGA_HS, VGA_SYNC_N, VGA_VS signals. The purpose of this module is to 
// hold all the necessary modules/components to operate a maze game with various obstacles and features
// using an N8 remote and a VGA disply.

module DE1_SoC (HEX0, HEX1, HEX2, HEX3, HEX4, HEX5, KEY, LEDR, SW,
					 CLOCK_50, VGA_R, VGA_G, VGA_B, VGA_BLANK_N, VGA_CLK, VGA_HS, VGA_SYNC_N, VGA_VS, N8_DATA_IN, N8_LATCH, N8_PULSE);
	output logic [6:0] HEX0, HEX1, HEX2, HEX3, HEX4, HEX5;
	output logic [9:0] LEDR;
	output logic N8_LATCH;
	output logic N8_PULSE;
	input logic [3:0] KEY;
	input logic [9:0] SW;
	input logic N8_DATA_IN;
	input CLOCK_50;
	output [7:0] VGA_R;
	output [7:0] VGA_G;
	output [7:0] VGA_B;
	output VGA_BLANK_N;
	output VGA_CLK;
	output VGA_HS;
	output VGA_SYNC_N;
	output VGA_VS;

	logic reset;
	logic [9:0] x;
	logic [8:0] y;
	logic [7:0] r, g, b;
	logic [9:0] xCeil, xFlr, yCeil, yFlr;
	logic [9:0] xfirst, xlast, yfirst, ylast;

	logic walls, lava_pits, teleport_pink, teleport_green, teleport_cyan, teleport_purple, teleport_grey, start_line, finish_line;
	logic wallblks, startblk, tpblks, lavablks, goalblk;
	logic gamestart, gameover, complete;
	logic up, down, left, right, select, start, a_button, b_button, ltch, pulse;
	logic shft_R, shft_L, shft_D, shft_U, press_A, press_start;
	
	assign reset = SW[9];
	assign LEDR[9] = select;
	assign LEDR[8] = start;

	// mapBlks takes 10-bit input signal x, and 9-bit input signal y to create a multitude of maze items 
	// to be displayed on the VGA display. Each of the outputs lava_pits to finish_line are used to 
	// appropriately draw each of these obstacles and useful items on the VGA display.
	mapBlks		    map    (.x, .y, .walls, .lava_pits, .teleport_pink, .teleport_green, .teleport_cyan, .teleport_purple, .teleport_grey, .start_line, .finish_line);

	// interactBlks takes 4 10-bit signals xCeil, xFlr, yCeil, yFlr that are used to
	// represent the current location of the player's block and will return signals 
	// startBlk, tpblks, lavablks, and goalblk represent an interaction between the
	// player block and any of the special blocks. This is used to adjust the position
	// of the player accordingly.	
	interactBlks intr_acts (.xCeil, .xFlr, .yCeil, .yFlr, .startblk, .tpblks, .lavablks, .goalblk);
	
	
	video_driver #(.WIDTH(640), .HEIGHT(480))
		v1 (.CLOCK_50, .reset, .x, .y, .r, .g, .b,
			 .VGA_R, .VGA_G, .VGA_B, .VGA_BLANK_N,
			 .VGA_CLK, .VGA_HS, .VGA_SYNC_N, .VGA_VS);
	
	// n8_driver is used to interface the n8 video game controller to the FPGA board. From this
	// driver module we can use the signals up, down, left, right, select, start, a, and b 
	// which correspond to physical buttons on the n8 controller.
	n8_driver n8_1 (.clk(CLOCK_50), .data_in(N8_DATA_IN), .ltch(N8_LATCH), .pulse(N8_PULSE), .up, .down, .left, .right, .select, .start, .a(a_button), .b(b_button));

	// n8_display is used to display the current action being done by the player on the
	// HEX displays when the player's block is not interacting with special blocks in 
	// the maze or will display special actions like if the player dies. This is 
	// done by taking in actions from the n8 controller like right, left, up etc. 
	// and based on the status of the game from the game_end module, this module
	// will output the corresponding state of the game on the HEX displays.
	n8_display n8_d (.clk(CLOCK_50), .right, .left, .up, .down, .select, .start, .a(a_button), .b(b_button), .startblk, .tpblks, .gameover, .complete, .HEX0, .HEX1, .HEX2, .HEX3, .HEX4, .HEX5);
	
	// filtering inputs from the n8 controller to ensure that each button
	// press is only counted once regardless of how long a button is
	// held down for.
	userInput bufR (.clock(CLOCK_50), .reset, .in(right), .out(shft_R)); 
	userInput bufL (.clock(CLOCK_50), .reset, .in(left), .out(shft_L));
	userInput bufD (.clock(CLOCK_50), .reset, .in(down), .out(shft_D));
	userInput bufU (.clock(CLOCK_50), .reset, .in(up), .out(shft_U));
	userInput bufA (.clock(CLOCK_50), .reset, .in(a_button), .out(press_A));
	userInput bufS (.clock(CLOCK_50), .reset, .in(start), .out(press_start));
		
	// blkPlayer is used to determine where to draw the player's block on the
	// VGA display. Inputs shft_L, shft_U, shft_D, shft_R are used to "move"
	// the player on the display based on which direction the player is pressing
	// on the controller. xCeil, xFlr, yCeil, and yFlr are ranges of values that are
	// used to draw the player block on the display.	
	blkPlayer player (.clk(CLOCK_50), .reset(gamestart), .left(shft_L), .up(shft_U), .down(shft_D), .right(shft_R), .press_A, .wallblks, .gameover, .xCeil, .xFlr, .yCeil, .yFlr);
	
	// collision is used to determine where the player cannot move into on the VGA display. 
	// this module takes filtered direction inputs from the n8 controller and returns the
	// proper position for the player's block based on if the player is able to move in 
	// that direction or not. 
	collision wllhit (.left(shft_L), .up(shft_U), .down(shft_D), .right(shft_R), .xCeil, .xFlr, .yCeil, .yFlr, .wallblks);
	
	// game_end is used to determine if the game should end based on in-game
	// circumstances such as falling in a lava pit. 
	game_end gmovr (.clk(CLOCK_50), .reset, .start_button(press_start), .lavablks, .goalblk, .gamestart, .gameover, .complete);

	// this always_ff block is used to determine where certain items should be colored
	// such as the player, walls, and special blocks like lava and teleportation devices.
	always_ff @(posedge CLOCK_50) begin
		if (x < xCeil && y < yCeil && x > xFlr && y > yFlr) 
			{r, g, b} <= 24'hC70039;
		else if (walls) 
			{r, g, b} <= 24'h000000;
		else if (lava_pits)
			{r, g, b} <= 24'h3900C7;
		else if (teleport_pink) 
			{r, g, b} <= 24'hFF00FF;
		else if (teleport_green)
			{r, g, b} <= 24'h00FF00;
		else if (teleport_cyan)
			{r, g, b} <= 24'h00FFFF;
		else if (teleport_purple)
			{r, g, b} <= 24'hF00FFE;
		else if (teleport_grey)
			{r, g, b} <= 24'h202020;
		else if (start_line || finish_line)
			{r, g, b} <= 24'hFFFF00;
		else
			{r, g, b} <= 24'hFFFFFF;
	end
	
endmodule
