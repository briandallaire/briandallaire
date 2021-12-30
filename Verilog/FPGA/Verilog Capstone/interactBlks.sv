// Brian Dellaire, Erik Michel
// EE 371
// Lab #6, Design Project

// interactBlks takes 10-bit inputs xCeil, xFlr, yCeil, yFlr and
// returns startBlk, tpblks, lavablks, and goalblk. The purpose of
// this module is to assign regions of the maze to a specific functions
// such as the start position of the player block or teleportation blocks.
// Information about the current position of the player block is used to 
// determine if the player is within an assigned region. 

module interactBlks (xCeil, xFlr, yCeil, yFlr, startblk, tpblks, lavablks, goalblk);
	
	input logic [9:0] xCeil, xFlr, yCeil, yFlr;
	output logic startblk, tpblks, lavablks, goalblk;

	assign startblk 	= xFlr >= 0 && yFlr >= 0 && xCeil <= 32 && yCeil <= 30;
	
	assign tpblks    = xFlr >= 224 && yFlr >= 150 && xCeil <= 256 && yCeil <= 180 || xFlr >= 416 && yFlr >= 90 && xCeil <= 448 && yCeil <= 120 ||
						     xFlr >= 0 && yFlr >= 450 && xCeil <= 32 && yCeil <= 480 || xFlr >= 288 && yFlr >= 240 && xCeil <= 320 && yCeil <= 270;
	
	assign lavablks  = xFlr >= 0 && yFlr >= 210 && xCeil <= 32 && yCeil <= 240 || xFlr >= 192 && yFlr >= 150 && xCeil <= 224 && yCeil <= 210 || xFlr >= 288 && yFlr >= 0 && xCeil <= 320 && yCeil <= 30 ||
							  xFlr >= 352 && yFlr >= 210 && xCeil <= 384 && yCeil <= 240 || xFlr >= 384 && yFlr >= 120 && xCeil <= 416 && yCeil <= 150 || xFlr >= 448 && yFlr >= 90 && xCeil <= 480 && yCeil <= 120 ||
							  xFlr >= 480 && yFlr >= 180 && xCeil <= 512 && yCeil <= 210 || xFlr >= 544 && yFlr >= 210 && xCeil <= 576 && yCeil <= 240 || xFlr >= 64 && yFlr >= 390 && xCeil <= 96 && yCeil <= 420 ||
							  xFlr >= 128 && yFlr >= 420 && xCeil <= 160 && yCeil <= 450 || xFlr >= 160 && yFlr >= 270 && xCeil <= 192 && yCeil <= 300 || xFlr >= 224 && yFlr >= 240 && xCeil <= 256 && yCeil <= 270 ||
							  xFlr >= 224 && yFlr >= 450 && xCeil <= 256 && yCeil <= 480 || xFlr >= 256 && yFlr >= 270 && xCeil <= 288 && yCeil <= 300 || xFlr >= 384 && yFlr >= 330 && xCeil <= 416 && yCeil <= 360 ||
							  xFlr >= 608 && yFlr >= 450 && xCeil <= 640 && yCeil <= 480;
								  
	assign goalblk = xFlr >= 544 && yFlr >= 390 && xCeil <= 576 && yCeil <= 420;	
	
endmodule 

// interactBlks_testbench tests the functionality of the interactBlks
// module above, meaning that each of the assigned regions on the maze
// display the proper functionality.

module interactBlks_testbench();

	logic [9:0] xCeil, xFlr, yCeil, yFlr;
	logic startblk, tpblks, lavablks, goalblk;

	interactBlks dut (.xCeil, .xFlr, .yCeil, .yFlr, .startblk, .tpblks, .lavablks, .goalblk);
	
	initial begin 
	
		xFlr <= 10'd0; yFlr <= 10'd0; xCeil <= 10'd16; yCeil <= 10'd16; #10;
		xFlr <= 10'd235; yFlr <= 10'd160; xCeil <= 10'd250; yCeil <= 10'd170; #10;
		xFlr <= 10'd360; yFlr <= 10'd220; xCeil <= 10'd380; yCeil <= 10'd200; #10;
		xFlr <= 10'd550; yFlr <= 10'd400; xCeil <= 10'd570; yCeil <= 10'd410; #10;
		xFlr <= 10'd16; yFlr <= 10'd100; xCeil <= 10'd20; yCeil <= 10'd110; #10;
		
		
		$stop;
		
	end
	
endmodule 