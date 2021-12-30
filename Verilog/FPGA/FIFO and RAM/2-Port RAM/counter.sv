// Brian Dallaire
// 04/23/2021
// EE 371
// Lab #2, Task 2

// counter takes the 1-bit inputs clk and reset and outputs the 5-bit output out. The
// main purpose of this module is to increment the ouput variable by 1 every clock cycle


module counter (clk, reset, out);

	input logic clk, reset;
	output logic [4:0] out;
	
	// always_ff block where on reset the output will reset to zero, 
	// but otherwise increment by 1 every positive edge of the clock.
	// When output reaches max capacity, it will naturally return to zero
	// the next increment.
	always_ff @(posedge clk) begin
		if(reset)
			out <= '0;
		else
			out <= out + 1;
	end
endmodule 

// counter_testbench tests the expected and unexpected cases of this module. For this simulation,
// I tested what happens when the output "overflows" to see if it returns to zero and keeps counting.
// I also tested what happens when reset is true in the middle of counting.

module counter_testbench();
	logic clk, reset;
	logic [4:0] out;
	
	counter dut (.clk, .reset, .out);
	
	parameter CLOCK_PERIOD=100;
	initial begin
		clk <= 0;
		forever #(CLOCK_PERIOD/2) clk <= ~clk; // Forever toggle the clock
	end
	
	initial begin
		//test to see if counter resets to zero after overflowing
		reset <= 1;  				@(posedge clk);
		reset <= 0;  repeat(34) @(posedge clk);
		
		//test to see if resetting in the middle of a count affects behavior
		reset <= 1;					@(posedge clk);
		reset <= 0;  repeat(5)  @(posedge clk);
		$stop;
	end
endmodule 