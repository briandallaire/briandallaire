// Brian Dallaire
// 11/12/2021
// EE 469
// Lab #3

// varSize_D_FF takes the 1-bit inputs clk and reset and the n-bit input
// d_in and outputs the n-bit output q_out. The purpose of this module is to 
// represent a n-bit wide register. That stores values and outputs them every
// clock cycle. 
 
module varSize_D_FF #(parameter WIDTH = 1) (clk, reset, d_in, q_out);

	input logic  clk, reset;
	input logic  [WIDTH - 1 : 0] d_in;
	output logic [WIDTH - 1 : 0] q_out;

	
	genvar i;
	
	generate 
	
		for(i = 0; i < WIDTH; i++) begin : PC_reg
			D_FF bitPC (.q(q_out[i]), .d(d_in[i]), .reset, .clk);
		end
		
	endgenerate 
	

endmodule 

// varSize_D_FF_testbench tests the relevant behaviors in this lab. This testbench
// tests the D_FF's capability of acting as a flip flop for inputs bigger than 
// 1-bit. Here I tested it using a size of 64.

module varSize_D_FF_testbench();

	logic clk, reset;
	logic [63:0] d_in;
	logic [63:0] q_out;
	
	varSize_D_FF #(.WIDTH(64)) dut (.clk, .reset, .d_in, .q_out);
	
	parameter CLOCK_PERIOD = 100;
	
	initial begin 
		clk <= 0;
		forever #(CLOCK_PERIOD/2) clk <= ~clk;
	end
	
	initial begin 
	
		reset <= 1; d_in <= 64'd34324;  @(posedge clk);
		reset <= 0; 			repeat(4)  @(posedge clk);
						d_in <= 64'd6823;   @(posedge clk);
									repeat(4)  @(posedge clk);
		
		$stop;
		
	end
endmodule 