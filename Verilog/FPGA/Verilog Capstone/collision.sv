// Brian Dellaire, Erik Michel
// EE 371
// Lab #6, Design Project

// collision takes 1-bit inputs left, up, down, right and 10-bit inputs
// xCeil, xFlr, yCeil, yFlr. collision returns 1-bit signal wallblks.
// The purpose of this module is to enable collision within the maze, 
// primarily so that the player cannot go through walls of the maze.

module collision (left, up, down, right, xCeil, xFlr, yCeil, yFlr, wallblks);

	input logic left, up, down, right;
	input logic [9:0] xCeil, xFlr, yCeil, yFlr;
	output logic wallblks;
	
	logic [9:0] x1, x2, y1, y2;

	assign x1 = (!left && !up && !down && right && xCeil != 640) ? (xFlr + 10'd32) : (left && !up && !down && !right && xFlr != 0) ? (xFlr - 10'd32) : xFlr;
	assign x2 = (!left && !up && !down && right && xCeil != 640) ? (xCeil + 10'd32) : (left && !up && !down && !right && xFlr != 0) ? (xCeil - 10'd32) : xCeil;
	assign y1 = (!left && up && !down && !right && yFlr != 0) ? (yFlr - 10'd30) : (!left && !up && down && !right && yCeil != 480) ? (yFlr + 10'd30) : yFlr;
	assign y2 = (!left && up && !down && !right && yFlr != 0) ? (yCeil - 10'd30) : (!left && !up && down && !right && yCeil != 480) ? (yCeil + 10'd30) : yCeil;
	
	assign wallblks = x1 >= 32 && y1 >= 0 && x2 <= 64 && y2 <= 90 || x1 >= 32 && y1 >= 120 && x2 <=64 && y2 <= 240 || x1 >= 32 && y1 >= 0 && x2 <= 96 && y2 <= 30 || 
						x1 >= 96 && y1 >= 120 && x2 <= 160 && y2 <= 180 || x1 >= 0 && y1 >= 240 && x2 <= 32 && y2 <= 300 || x1 >= 64 && y1 >= 210 && x2 <= 92 && y2 <= 300 ||
						x1 >= 64 && y1 >= 240 && x2 <= 224 && y2 <= 270 || x1 >= 128 && y1 >= 180 && x2 <= 192 && y2 <= 210 || x1 >= 128 && y1 >= 150 && x2 <= 160 && y2 <= 210 ||
						x1 >= 96 && y1 >= 60 && x2 <= 160 && y2 <= 90 || x1 >= 128 && y1 >= 30 && x2 <= 160 && y2 <= 90 || x1 >= 128 && y1 >= 30 && x2 <= 224 && y2 <= 60 ||
						x1 >= 192 && y1 >= 30 && x2 <= 224 && y2 <= 150 || x1 >= 192 && y1 >= 90 && x2 <= 256 && y2 <= 150 || x1 >= 256 && y1 >= 0 && x2 <= 288 && y2 <= 60 ||
						x1 >= 256 && y1 >= 150 && x2 <= 288 && y2 <= 180 || x1 >= 224 && y1 >= 210 && x2 <= 352 && y2 <= 240 || x1 >= 288 && y1 >= 90 && x2 <= 352 && y2 <= 120 || //end of top-left quadrant
						
						x1 >= 320 && y1 >= 0 && x2 <= 352 && y2 <= 270 || x1 >= 320 && y1 >= 150 && x2 <= 416 && y2 <= 210 || x1 >= 384 && y1 >= 30 && x2 <= 416 && y2 <= 120 ||
						x1 >= 384 && y1 >= 60 && x2 <= 480 && y2 <= 90 || x1 >= 448 && y1 >= 30 && x2 <= 480 && y2 <= 90 || x1 >= 448 && y1 >= 120 && x2 <= 480 && y2 <= 210 ||
						x1 >= 512 && y1 >= 0 && x2 <= 544 && y2 <= 90 || x1 >= 512 && y1 >= 0 && x2 <= 640 && y2 <= 30 || x1 >= 512 && y1 >= 120 && x2 <= 608 && y2 <= 150 ||
						x1 >= 576 && y1 >= 60 && x2 <= 608 && y2 <= 150 || x1 >= 544 && y1 >= 180 && x2 <= 608 && y2 <= 210 ||	 // end of top-right quadrant
						
						x1 >= 0 && y1 >= 420 && x2 <= 64 && y2 <= 450 || x1 >= 32 && y1 >= 330 && x2 <= 64 && y2 <= 390 || x1 >= 96 && y1 >= 330 && x2 <= 128 && y2 <= 360 ||
						x1 >= 96 && y1 >= 390 && x2 <= 128 && y2 <= 450 || x1 >= 128 && y1 >= 300 && x2 <= 192 && y2 <= 330 || x1 >= 160 && y1 >= 360 && x2 <= 192 && y2 <= 450 ||
						x1 >= 224 && y1 >= 300 && x2 <= 256 && y2 <= 360 || x1 >= 224 && y1 >= 390 && x2 <= 256 && y2 <= 450 || x1 >= 288 && y1 >= 270 && x2 <= 320 && y2 <= 480 || // end of bottom-left quadrant
						
						x1 >= 288 && y1 >= 450 && x2 <= 352 && y2 <= 480 || x1 >= 352 && y1 >= 300 && x2 <= 384 && y2 <= 420 || x1 >= 384 && y1 >= 240 && x2 <= 544 && y2 <= 270 ||
						x1 >= 384 && y1 >= 420 && x2 <= 416 && y2 <= 450 || x1 >= 416 && y1 >= 240 && x2 <= 448 && y2 <= 300 || x1 >= 416 && y1 >= 330 && x2 <= 480 && y2 <= 390 ||
						x1 >= 448 && y1 >= 420 && x2 <= 480 && y2 <= 480 || x1 >= 480 && y1 >= 300 && x2 <= 608 && y2 <= 330 || x1 >= 512 && y1 >= 360 && x2 <= 544 && y2 <= 450 ||
						x1 >= 576 && y1 >= 360 && x2 <= 576 && y2 <= 390 || x1 >= 576 && y1 >= 420 && x2 <= 608 && y2 <= 480 || x1 >= 576 && y1 >= 240 && x2 <= 640 && y2 <= 270; // end of bottom-right quadrant

endmodule 


// collision_testbench is used to test the functionality of the collision
// module above.

module collision_testbench();

	logic left, up, down, right;
	logic [9:0] xCeil, xFlr, yCeil, yFlr;
	logic wallblks;
	
	collision dut (.left, .up, .down, .right, .xCeil, .xFlr, .yCeil, .yFlr, .wallblks);
	
	initial begin 
		left <= 0; right <= 0; up <= 0; down <= 0; xFlr <= 10'd0; yFlr <= 10'd0; xCeil <= 10'd32; yCeil <= 10'd30; #10;
		left <= 0; right <= 1; up <= 0; down <= 0; xFlr <= 10'd0; yFlr <= 10'd0; xCeil <= 10'd32; yCeil <= 10'd30; #10;
		left <= 0; right <= 0; up <= 0; down <= 0; xFlr <= 10'd480; yFlr <= 10'd120; xCeil <= 10'd512; yCeil <= 10'd150; #10;
		left <= 1; right <= 0; up <= 0; down <= 0; xFlr <= 10'd480; yFlr <= 10'd120; xCeil <= 10'd512; yCeil <= 10'd150; #10;
		left <= 0; right <= 0; up <= 0; down <= 0; xFlr <= 10'd320; yFlr <= 10'd270; xCeil <= 10'd352; yCeil <= 10'd300; #10;
		left <= 0; right <= 0; up <= 1; down <= 0; xFlr <= 10'd320; yFlr <= 10'd270; xCeil <= 10'd352; yCeil <= 10'd300; #10;
		left <= 0; right <= 0; up <= 0; down <= 0; xFlr <= 10'd160; yFlr <= 10'd330; xCeil <= 10'd192; yCeil <= 10'd360; #10;
		left <= 0; right <= 0; up <= 0; down <= 1; xFlr <= 10'd160; yFlr <= 10'd330; xCeil <= 10'd192; yCeil <= 10'd360; #10;
		left <= 0; right <= 0; up <= 0; down <= 0; xFlr <= 10'd320; yFlr <= 10'd270; xCeil <= 10'd352; yCeil <= 10'd300; #10;
		left <= 0; right <= 0; up <= 0; down <= 1; xFlr <= 10'd320; yFlr <= 10'd270; xCeil <= 10'd352; yCeil <= 10'd300; #10;

		
		$stop;
	end
endmodule 