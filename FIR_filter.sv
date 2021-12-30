// Erik Michel & Brian Dallaire
// 5/23/2021
// EE 371
// Lab #5, Task 2

// FIR_filter takes in the 1-bit inputs clk, reset, and en and the 24-bit input dataIn
// and outputs the 24-bit input dataOut. The main purpose of this module is to replicate
// an averaging Finite Impulse Response (FIR) filter in order to remove noise from a sound. 
// In this FIR filter, we remove small deviations in sound by averaging the 8 adjacent samples.

module FIR_filter (clk, reset, en, dataIn, dataOut);

	input logic clk, reset, en;
	input logic [23:0] dataIn;
	output logic [23:0] dataOut;
	
	logic [6:0][23:0] sample;
	logic [6:0][23:0] divided;

	// dataOut is assigned the initial dataIn divided by 8, as well as all of the other samples divided by 8. 
	// In total, dataOut will equal dataIn after every sample has been added, assuming en were true the entire
	// process. 
	assign dataOut = (en) ? ({{3{dataIn[23]}}, dataIn[23:3]} + divided[6] + divided[5] + divided[4] + divided[3]
																				+ divided[2] + divided[1] + divided[0]) : dataOut; 
	
	// this generate statement takes 7 samples of dataIn and divides them by 8. Each sample and division occurs
	// after every clock cycle. 
	genvar i;
	generate 
		for(i = 0; i < 7; i++) begin : filter
			if(i == 0) begin
				// wideDFF takes the 1-bit inputs clk, reset, and en and the 24-bit input dataIn
				// and outputs the 24-bit output sample[i]. The main purpose of this module is 
				// to act as the very first register of the FIR filter circuit
				wideDFF dff1 (.clk, .reset, .en, .d(dataIn), .q(sample[i]));
			end else begin
				// wideDFF takes the 1-bit inputs clk, reset, and en and the 24-bit input sample[i-1]
				// and outputs the 24-bit output sample[i]. The main purpose of this module is to act
				// as the following registers and moving the output of the previous register into the
				// next register
				wideDFF dffs (.clk, .reset, .en, .d(sample[i-1]), .q(sample[i]));
			end
			// this assign divides the i'th sample by 8
			assign divided[i] = {{3{sample[i][23]}}, sample[i][23:3]};
		end
	endgenerate															  
endmodule 

// FIR_filter_testbench tests for both the expected and unexpected cases of the FIR_filter module.
// In this testbench, we tested to see what happens with different input values, and what happens
// when en is no longer true before all of the samples can be divided and added to the output. 

module FIR_filter_testbench();
	logic clk, reset, en;
	logic [23:0] dataIn;
	logic [23:0] dataOut;
	
	FIR_filter dut (.clk, .reset, .en, .dataIn, .dataOut);

	parameter CLOCK_PERIOD = 100;
	initial begin 
		clk <= 0;
		forever # (CLOCK_PERIOD/2) clk <= ~clk; //Forever toggle clock
	end 
	
	initial begin 
		reset <= 1; en <= 0; dataIn <= 24'd64; @(posedge clk);
		reset <= 0; en <= 1;  		  repeat(10)@(posedge clk);
		reset <= 0; en <= 0; dataIn <= 24'd32; repeat(3) @(posedge clk);
		reset <= 0; en <= 1;  		  repeat(10)@(posedge clk);
		reset <= 0; en <= 0; dataIn <= 24'd48; repeat(3) @(posedge clk);
		reset <= 0; en <= 1;  		  repeat(6)@(posedge clk);
		reset <= 0; en <= 0;			  repeat(3)@(posedge clk);
		reset <= 0; en <= 1;		     repeat(4)@(posedge clk);
		$stop;
	end
endmodule 