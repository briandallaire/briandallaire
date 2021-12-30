// Brian Dellaire, Erik Michel
// EE 371
// Lab #6, Design Project

// mapBlks takes a 10-bit input x and a 9-bit input y and returns 1-bit signals
// lava_pits, teleport_pink, teleport_green, teleport_cyan, teleport_purple, teleport_grey,
// start_line, and finish_line. The purpose of this module is to draw the main points of 
// interest on the maze along with the walls that make up the maze. 

module mapBlks(x, y, walls, lava_pits, teleport_pink, teleport_green, teleport_cyan, teleport_purple, teleport_grey, start_line, finish_line);

	input logic [9:0] x;
	input logic [8:0] y;
	output logic walls, lava_pits, teleport_pink, teleport_green, teleport_cyan, teleport_purple, teleport_grey, start_line, finish_line;

	assign walls = x > 32 && y > 0 && x < 64 && y < 90 || x > 32 && y > 120 && x <64 && y < 240 || x > 32 && y > 0 && x < 96 && y < 30 || 
						x > 96 && y > 120 && x < 160 && y < 180 || x > 0 && y > 240 && x < 32 && y < 300 || x > 64 && y > 210 && x < 92 && y < 300 ||
						x > 64 && y > 240 && x < 224 && y < 270 || x > 128 && y > 180 && x < 192 && y < 210 || x > 128 && y > 150 && x < 160 && y < 210 ||
						x > 96 && y > 60 && x < 160 && y < 90 || x > 128 && y > 30 && x < 160 && y < 90 || x > 128 && y > 30 && x < 224 && y < 60 ||
						x > 192 && y > 30 && x < 224 && y < 150 || x > 192 && y > 90 && x < 256 && y < 150 || x > 256 && y > 0 && x < 288 && y < 60 ||
						x > 256 && y > 150 && x < 288 && y < 180 || x > 224 && y > 210 && x < 352 && y < 240 || x > 288 && y > 90 && x < 352 && y < 120 || //end of top-left quadrant
						
						x > 320 && y > 0 && x < 352 && y < 270 || x > 320 && y > 150 && x < 416 && y < 210 || x > 384 && y > 30 && x < 416 && y < 120 ||
						x > 384 && y > 60 && x < 480 && y < 90 || x > 448 && y > 30 && x < 480 && y < 90 || x > 448 && y > 120 && x < 480 && y < 210 ||
						x > 512 && y > 0 && x < 544 && y < 90 || x > 512 && y > 0 && x < 640 && y < 30 || x > 512 && y > 120 && x < 608 && y < 150 ||
						x > 576 && y > 60 && x < 608 && y < 150 || x > 544 && y > 180 && x < 608 && y < 210 ||	 // end of top-right quadrant
						
						x > 0 && y > 420 && x < 64 && y < 450 || x > 32 && y > 330 && x < 64 && y < 390 || x > 96 && y > 330 && x < 128 && y < 360 ||
						x > 96 && y > 390 && x < 128 && y < 450 || x > 128 && y > 300 && x < 192 && y < 330 || x > 160 && y > 360 && x < 192 && y < 450 ||
						x > 224 && y > 300 && x < 256 && y < 360 || x > 224 && y > 390 && x < 256 && y < 450 || x > 288 && y > 270 && x < 320 && y < 480 || // end of bottom-left quadrant
						
						x > 288 && y > 450 && x < 352 && y < 480 || x > 352 && y > 300 && x < 384 && y < 420 || x > 384 && y > 240 && x < 544 && y < 270 ||
						x > 384 && y > 420 && x < 416 && y < 450 || x > 416 && y > 240 && x < 448 && y < 300 || x > 416 && y > 330 && x < 480 && y < 390 ||
						x > 448 && y > 420 && x < 480 && y < 480 || x > 480 && y > 300 && x < 608 && y < 330 || x > 512 && y > 360 && x < 544 && y < 450 ||
						x > 576 && y > 360 && x < 576 && y < 390 || x > 576 && y > 420 && x < 608 && y < 480 || x > 576 && y > 240 && x < 640 && y < 270;	// end of bottom-right quadrant
	
	assign lava_pits   	= x > 0 && y > 210 && x < 32 && y < 240 || x > 192 && y > 150 && x < 224 && y < 210 || x > 288 && y > 0 && x < 320 && y < 30 ||
								  x > 352 && y > 210 && x < 384 && y < 240 || x > 384 && y >120 && x < 416 && y < 150 || x > 448 && y > 90 && x < 480 && y < 120 ||
								  x > 480 && y > 180 && x < 512 && y < 210 || x > 544 && y > 210 && x < 576 && y < 240 || x > 64 && y > 390 && x < 96 && y < 420 ||
								  x > 128 && y > 420 && x < 160 && y < 450 || x > 160 && y > 270 && x < 192 && y < 300 || x > 224 && y > 240 && x < 256 && y < 270 ||
								  x > 224 && y > 450 && x < 256 && y < 480 || x > 256 && y > 270 && x < 288 && y < 300 || x > 384 && y > 330 && x < 416 && y < 360 ||
								  x > 608 && y > 450 && x < 640 && y < 480;
								  
	assign teleport_pink = x > 224 && y > 150 && x < 256 && y < 180 || x > 416 && y > 30 && x < 448 && y < 60;
	
	assign teleport_green = x > 416 && y > 90 && x < 448 && y < 120 || x > 32 && y > 240 && x < 64 && y < 270;
	
	assign teleport_cyan = x > 0 && y > 450 && x < 32 && y < 480 || x > 256 && y > 240 && x < 288 && y < 270;
	
	assign teleport_purple = x > 288 && y > 240 && x < 320 && y < 270 || x > 352 && y > 420 && x < 384 && y < 450;
	
	assign teleport_grey = x > 544 && y > 360 && x < 576 && y < 390 || x > 544 && y > 420 && x < 576 && y < 450;
	
	assign start_line = x > 0 && y > 0 && x < 32 && y < 30;
	
	assign finish_line = x > 544 && y > 390 && x < 576 && y < 420;
	
endmodule 


// mapBlks_testbench tests the functionality of the mapBlks module above

module mapBlks_testbench();

	logic [9:0] x;
	logic [8:0] y;
	logic walls, lava_pits, teleport_pink, teleport_green, teleport_cyan, teleport_purple, teleport_grey, start_line, finish_line;
	
	mapBlks dut (.x, .y, .walls, .lava_pits, .teleport_pink, .teleport_green, .teleport_cyan, .teleport_purple, .teleport_grey, .start_line, .finish_line);

	initial begin 
		x <= 10'd42; y <= 9'd80; #10;
		x <= 10'd200; y <= 9'd160; #10;
		x <= 10'd250; y <= 9'd170; #10;
		x <= 10'd435; y <= 9'd95; #10;
		x <= 10'd16; y <= 9'd477; #10;
		x <= 10'd310; y <= 9'd252; #10;
		x <= 10'd566; y <= 9'd385; #10;
		x <= 10'd10; y <= 9'd20; #10;
		x <= 10'd555; y <= 9'd414; #10;
		x <= 10'd16; y <= 10'd100; #10;
		
		$stop;
	end
	
endmodule 