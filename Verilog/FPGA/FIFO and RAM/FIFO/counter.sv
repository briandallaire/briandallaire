// Brian Dallaire
// 04/23/2021
// EE 371
// Lab #2, Task 3

// counter takes the 1-bit inputs clk, reset and incr and outputs the 5-bit output out. The
// main purpose of this module is to increment the ouput variable by 1 every clock cycle only
// when incr is true. If incr is not true, the count will not increment the output. 


module counter #(parameter DEPTH = 4) (clk, reset, incr, out);

	input logic clk, reset, incr;
	output logic [DEPTH-1:0] out;

	// always_ff block where on reset the output will reset to zero, 
	// but otherwise increment by 1 every positive edge of the clock so
	// long as incr is true. If incr is not true, out will not increment
	// When output reaches max capacity, it will naturally return to zero
	// the next increment.
	always_ff @(posedge clk) begin
		if(reset)
			out <= '0;
		else if(incr)
			out <= out + 1'b1;
		else
			out <= out;
	end
endmodule 

// counter_testbench tests the expected and unexpected cases of this module. For this simulation,
// I tested what happens when the output "overflows" to see if it returns to zero and keeps counting.
// I also tested what happens when reset is true in the middle of counting. I also tested if counter
// does not count when incr is not true.

module counter_testbench();
	logic clk, reset, incr;
	logic [3:0] out;
	
	counter dut (.clk, .reset, .incr, .out);
	
	parameter CLOCK_PERIOD=100;
	initial begin
		clk <= 0;
		forever #(CLOCK_PERIOD/2) clk <= ~clk; // Forever toggle the clock
	end
	
	initial begin
		//test to see if counter resets to zero after overflowing
		reset <= 1;  incr <= 1;				  @(posedge clk);
		reset <= 0;  				repeat(20) @(posedge clk);
		
		//test to see if counter does not move when incr is 0;
					    incr <= 0; repeat(5)  @(posedge clk);
						 
		//test to see if resetting in the middle of a count affects behavior
		reset <= 1;	 incr <= 1;				  @(posedge clk);
		reset <= 0;  				repeat(5)  @(posedge clk);
		$stop;
	end
endmodule 