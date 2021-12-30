// Brian Dellaire, Erik Michel
// EE 371
// Lab #6, Design Project

// blkPLayer takes 1-bit input clk, reset, left, up, down, right, press_A, wallblks,
// and gameover. blkPlayer returns 10-bit signals xCeil, xFlr, yCeil, yFlr.
// This module is used to control the player's block movement depending on the
// inputs given from an n8 controller and other relevant maze/game-related signals.

module blkPlayer (clk, reset, left, up, down, right, press_A, wallblks, gameover, xCeil, xFlr, yCeil, yFlr);
	input logic clk, reset, left, up, down, right, press_A, wallblks, gameover;
	output logic [9:0] xCeil, xFlr, yCeil, yFlr;
	
	always_ff @(posedge clk) begin
		if (reset) begin
			xFlr <= 0;
			yFlr <= 0;
			xCeil <= 32;
			yCeil <= 30;
		end else if (gameover) begin
			xFlr <= 640;
			yFlr <= 0;
			xCeil <= 640;
			yCeil <= 0;
		end else if (!left && !up && !down && right && xCeil != 640 && !wallblks && !gameover) begin
			xFlr <= xFlr + 10'd32;
			xCeil <= xCeil + 10'd32;
		end else if (left && !up && !down && !right && xFlr != 0 && !wallblks && !gameover) begin
			xFlr <= xFlr - 10'd32;
			xCeil <= xCeil - 10'd32;
		end else if (!left && !up && down && !right && yCeil != 480 && !wallblks && !gameover) begin
			yFlr <= yFlr + 10'd30;
			yCeil <= yCeil + 10'd30;
		end else if (!left && up && !down && !right && yFlr != 0 && !wallblks && !gameover) begin
			yFlr <= yFlr - 10'd30;
			yCeil <= yCeil - 10'd30;
		end else if (xFlr == 224 && xCeil == 256 && yFlr == 150 && yCeil == 180 && press_A && !left && !up && !down && !right) begin
			xFlr  <= 416;
			xCeil <= 448;
			yFlr  <= 30;
			yCeil <= 60;
		end else if (xFlr == 416 && xCeil == 448 &&  yFlr == 90 && yCeil == 120 && press_A && !left && !up && !down && !right) begin
			xFlr  <= 32;
			xCeil <= 64;
			yFlr  <= 240;
			yCeil <= 270;
		end else if (xFlr == 0 && xCeil == 32 && yFlr == 450 && yCeil == 480 && press_A && !left && !up && !down && !right) begin
			xFlr  <= 256;
			xCeil <= 288;
			yFlr  <= 240;
			yCeil <= 270;
		end else if (xFlr == 288 && xCeil == 320 && yFlr == 240 && yCeil == 270 && press_A && !left && !up && !down && !right) begin
			xFlr  <= 352;
			xCeil <= 384;
			yFlr  <= 420;
			yCeil <= 450;
		end else if ((xFlr == 544 && xCeil == 576 && yFlr == 360 && yCeil == 390 || xFlr == 544 && xCeil == 576 && yFlr == 420 && yCeil == 450) && !left && !up && !down && !right) begin 
			xFlr  <= 0;
			xCeil <= 32;
			yFlr  <= 0;
			yCeil <= 30;
		end 
	end

endmodule 

// blkPlayer_testbench is used to test the functionality of the collision
// module above.

module blkPlayer_testbench();

	logic clk, reset, left, up, down, right, press_A, wallblks, gameover;
	logic [9:0] xCeil, xFlr, yCeil, yFlr;

	blkPlayer dut (.clk, .reset, .left, .up, .down, .right, .press_A, .wallblks, .gameover, .xCeil, .xFlr, .yCeil, .yFlr);

	parameter CLOCK_PERIOD = 100;
	initial begin 
		clk <= 0;
		forever # (CLOCK_PERIOD/2) clk <= ~clk; //Forever toggle clock
	end
	
	initial begin 
		reset <= 1; up <= 0; down <= 0; left <= 0; right <= 0; press_A <= 0; wallblks <= 0; gameover <= 0;	repeat(1)@(posedge clk);
		reset <= 0; up <= 0; down <= 1; left <= 0; right <= 0; press_A <= 0; wallblks <= 0; gameover <= 0; repeat(3)@(posedge clk);
		reset <= 0; up <= 0; down <= 0; left <= 0; right <= 1; press_A <= 0; wallblks <= 0; gameover <= 0;	repeat(2)@(posedge clk);
		reset <= 0; up <= 1; down <= 0; left <= 0; right <= 0; press_A <= 0; wallblks <= 0; gameover <= 0;	repeat(2)@(posedge clk);
		reset <= 0; up <= 0; down <= 0; left <= 0; right <= 1; press_A <= 0; wallblks <= 0; gameover <= 0;	repeat(1)@(posedge clk);
		reset <= 0; up <= 1; down <= 0; left <= 0; right <= 0; press_A <= 0; wallblks <= 0; gameover <= 0;	repeat(1)@(posedge clk);
		reset <= 0; up <= 0; down <= 0; left <= 0; right <= 1; press_A <= 0; wallblks <= 0; gameover <= 0;	repeat(4)@(posedge clk);
		reset <= 0; up <= 0; down <= 1; left <= 0; right <= 0; press_A <= 0; wallblks <= 0; gameover <= 0;	repeat(2)@(posedge clk);
		reset <= 0; up <= 0; down <= 0; left <= 0; right <= 1; press_A <= 0; wallblks <= 0; gameover <= 0;	repeat(1)@(posedge clk);
		reset <= 0; up <= 0; down <= 1; left <= 0; right <= 0; press_A <= 0; wallblks <= 0; gameover <= 0;	repeat(2)@(posedge clk);
		reset <= 0; up <= 0; down <= 0; left <= 0; right <= 1; press_A <= 0; wallblks <= 0; gameover <= 0;	repeat(1)@(posedge clk);
		reset <= 0; up <= 0; down <= 1; left <= 0; right <= 0; press_A <= 0; wallblks <= 0; gameover <= 0;	repeat(2)@(posedge clk);
		reset <= 0; up <= 0; down <= 0; left <= 1; right <= 0; press_A <= 0; wallblks <= 0; gameover <= 0;	repeat(2)@(posedge clk);
		reset <= 0; up <= 1; down <= 0; left <= 0; right <= 0; press_A <= 0; wallblks <= 0; gameover <= 0;	repeat(1)@(posedge clk);
		reset <= 0; up <= 0; down <= 0; left <= 0; right <= 0; press_A <= 1; wallblks <= 0; gameover <= 0;	repeat(1)@(posedge clk); //gets to first teleport
		
		reset <= 0; up <= 1; down <= 0; left <= 0; right <= 0; press_A <= 0; wallblks <= 0; gameover <= 0;	repeat(2)@(posedge clk); //try to go past ceiling
		reset <= 0; up <= 0; down <= 0; left <= 0; right <= 1; press_A <= 0; wallblks <= 0; gameover <= 0;	repeat(4)@(posedge clk); //try to go past wall
		reset <= 0; up <= 0; down <= 1; left <= 0; right <= 0; press_A <= 0; wallblks <= 0; gameover <= 0;	repeat(3)@(posedge clk);
		reset <= 0; up <= 0; down <= 0; left <= 1; right <= 0; press_A <= 0; wallblks <= 0; gameover <= 0;	repeat(4)@(posedge clk); 
		reset <= 0; up <= 0; down <= 0; left <= 0; right <= 0; press_A <= 0; wallblks <= 0; gameover <= 1;	repeat(1)@(posedge clk); //go into lava pit
		reset <= 0; up <= 0; down <= 0; left <= 1; right <= 0; press_A <= 0; wallblks <= 0; gameover <= 1;	repeat(2)@(posedge clk); 

		
		
	$stop;
	end
endmodule 