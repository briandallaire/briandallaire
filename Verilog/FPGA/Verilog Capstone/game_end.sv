// Brian Dellaire, Erik Michel
// EE 371
// Lab #6, Design Project

// game_end takes the 1-bit inputs clk, reset, start_button, lavablks, and goalblk and outputs
// the 1-bit outputs gamestart, gameover, and complete. The main purpose of this module is to use
// the known information to determine when the game is over, complete, or starting.

module game_end (clk, reset, start_button, lavablks, goalblk, gamestart, gameover, complete);
	
	input logic clk, reset, start_button, lavablks, goalblk;
	output logic gamestart, gameover, complete;
	
	always_ff @(posedge clk) begin
		if (reset || start_button) begin
			gameover <= 0;
			complete <= 0;
			gamestart <= 1;
		end else if (lavablks) begin
			gameover <= 1;
		end else if (goalblk) begin
			complete <= 1;
			gameover <= 1;
		end else if (gameover != 1) begin
			gamestart <= 0;
		end
	end
	
endmodule 

// game_end_testbench is used to test the functionality of the collision
// module above.

module game_end_testbench();

	logic clk, reset, start_button, lavablks, goalblk;
	logic gameover, complete;
	
	game_end dut (.clk, .reset, .start_button, .lavablks, .goalblk, .gameover, .complete);
	
	parameter CLOCK_PERIOD = 100;
	initial begin 
		clk <= 0;
		forever # (CLOCK_PERIOD/2) clk <= ~clk; //Forever toggle clock
	end
	initial begin 
		reset <= 1; start_button <= 0; lavablks <= 0; goalblk <= 0; repeat(1) @(posedge clk);
		reset <= 0; start_button <= 0; lavablks <= 0; goalblk <= 1; repeat(5) @(posedge clk);
		reset <= 0; start_button <= 1; lavablks <= 0; goalblk <= 0; repeat(1) @(posedge clk);
		reset <= 0; start_button <= 0; lavablks <= 1; goalblk <= 0; repeat(5) @(posedge clk);
		reset <= 0; start_button <= 1; lavablks <= 0; goalblk <= 0; repeat(1) @(posedge clk);
		reset <= 0; start_button <= 0; lavablks <= 0; goalblk <= 1; repeat(2) @(posedge clk);
		reset <= 1; start_button <= 0; lavablks <= 0; goalblk <= 0; repeat(2) @(posedge clk);
		reset <= 0; start_button <= 0; lavablks <= 0; goalblk <= 0; repeat(1) @(posedge clk);

	$stop;	
	end
endmodule 