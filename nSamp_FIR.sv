// Erik Michel & Brian Dallaire
// 5/23/2021
// EE 371
// Lab #5, Task 3

// nSamp_FIR takes in the 1-bit inputs clk, reset, and en and the 24-bit input dataIn
// and outputs the 24-bit input dataOut. The main purpose of this module is to replicate
// a Finite Impulse Response (FIR) filter that takes an N number of samples.

module nSamp_FIR #(parameter N = 16) (clk, reset, en, dataIn, dataOut);

	input logic clk, reset, en;
	input logic [23:0] dataIn;
	output logic [23:0] dataOut;
	
	localparam logn = $clog2(N);
	
	logic [N-1:0][23:0] sample;
	logic [23:0] divided;
	logic [23:0] accum;
	logic signed [31:0] oldVal;
	
	// this assign divides the current sample by N
	assign divided = {{logn{dataIn[23]}}, dataIn[23:logn]};
	
	// this assign will determine the value of oldVal to be the
	// the last component of the buffer
	assign oldVal = sample[N - 1];

	// this assign compiles the divided, oldest (from buffer),
   //	and accumulator values to determine the value of dataOut 
	// if en is true. If not, dataOut maintains its value
	assign dataOut = (en) ? (divided + (-oldVal) + accum) : dataOut;
	
	// wideDFF takes the 1-bit inputs clk, reset, and en and the 24-bit input
	// dataOut and outputs the 24-bit output accum. The main purpose of this
	// module is to act as the register for the accumulator.
	wideDFF accumltr(.clk, .reset, .en, .d(dataOut), .q(accum));
	
	// this generate statement represents a buffer size of N. It will take the sample 
	// divided by N and buffer this value for N clock cycles before subtracting it from
	// the output.
	genvar i;
	generate
		for(i = 0; i < N; i++) begin : filter
			if (i == 0) 	
				// wideDFF takes the 1-bit inputs clk, reset, and en and the 24-bit input
				// divided and outputs the 24-bit output sample[i]. The main purpose of this
				// module is to input the divided sample into the beginning of the buffer
				wideDFF dffin   (.clk, .reset, .en, .d(divided), .q(sample[i]));
			else
				// wideDFF takes the 1-bit inputs clk, reset, and en and the 24-bit input
				// sample[i-1] and outputs the 24-bit output sample[i]. The main purpose of
				// this module is to move the divided sample through the buffer by one spot
				wideDFF dffshft (.clk, .reset, .en, .d(sample[i - 1]), .q(sample[i]));
		end		
	endgenerate		
endmodule 

// nSamp_FIR_testbench tests for both the expected and unexpected cases of the FIR_filter module.
// In this testbench, we tested to see what happens with different input values, and what happens
// when en is no longer true before the first value into the buffer passes through. 

module nSamp_FIR_testbench();
	logic clk, reset, en;
	logic [23:0] dataIn;
	logic [23:0] dataOut;
	
	nSamp_FIR dut (.clk, .reset, .en, .dataIn, .dataOut);

	parameter CLOCK_PERIOD = 100;
	initial begin 
		clk <= 0;
		forever # (CLOCK_PERIOD/2) clk <= ~clk; //Forever toggle clock
	end 
	
	initial begin 
		reset <= 1; en <= 0; dataIn <= 24'd64; @(posedge clk);
		reset <= 0; en <= 1;  		  repeat(16)@(posedge clk);
		reset <= 0; en <= 0; dataIn <= 24'd32; @(posedge clk);
		reset <= 0; en <= 1;  		  repeat(18)@(posedge clk);
		reset <= 0; en <= 0; dataIn <= 24'd48; repeat(3) @(posedge clk);
		reset <= 0; en <= 1;  		  repeat(6)@(posedge clk);
		reset <= 0; en <= 0;			  repeat(3)@(posedge clk);
		reset <= 0; en <= 1;		     repeat(12)@(posedge clk);
		$stop;
	end
endmodule 