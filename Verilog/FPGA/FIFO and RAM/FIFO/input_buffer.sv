// Brian Dallaire
// 04/23/2021
// EE 371
// Lab #2, Task 3

// input_buffer takes the 1-bit input clk, reset, and press and outputs the 1-bit output
// out. The purpose of this module is to prevent keys on the FPGA board from outputting 
// more than once in one press.

module input_buffer(clk, reset, press, out);
	input logic clk, reset, press;
	output logic out;
	logic PS, NS;
	
	// this always_comb block is used to determine when out should be true.
	// the next state is determined by press, so only the first time when
	// ps is not press will out be true when press is true. So long as
	// press stays true, the present state from then on will be press,
	// making out = 0
	always_comb begin
		NS = press;
		out = (~PS & press);
	end
	
	// This always_ff block is used to reset the present state of the FSM to 0 when reset is true,
	// and to update the present state to the next state every positive edge of the clock otherwise.
	always_ff @(posedge clk) begin
		if(reset) 
			PS <= 0;
		else 
			PS <= NS;
		
	end
	
endmodule 

// input_buffer_testbench tests every case this module can face. When press is true for over 10 clock cycles,
// when press is true for 5 clock cycles, and when press is true for 1 clock cycle. For every case, out should
// only be true for one clock cycle.

module input_buffer_testbench();
	logic clk, reset, press;
	logic out;
	
	input_buffer dut (.clk, .reset, .press, .out);
	
	parameter CLOCK_PERIOD=100;
	initial begin
		clk <= 1'b0;
		forever #(CLOCK_PERIOD/2) clk <= ~clk;
	end
	
	initial begin 
	
		reset <= 1;									@(posedge clk);
		reset <= 0;	press <= 0;					@(posedge clk);
						press <= 1; repeat(10)  @(posedge clk);
						press <= 0; 			   @(posedge clk);
						press <= 1; repeat(5)   @(posedge clk);
						press <= 0;				   @(posedge clk);
						press <= 1; 				@(posedge clk);
						press <= 0; repeat(3)   @(posedge clk);
		
		$stop;
	end
endmodule 