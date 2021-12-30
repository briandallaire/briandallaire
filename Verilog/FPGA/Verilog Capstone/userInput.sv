// Brian Dellaire, Erik Michel
// 6/7/2021
// EE 371
// Lab #6, Design Project

// userInput takes a 1-bit clock, reset, and in signal 
// and returns a 1-bit out signal. This module is used to 
// ensure that an input signal only remains ON for a single
// clock cycle. A raw input signal in is taken and regardless
// of how long in is ON for, the output will only be ON for a
// single clock cycle once the in signal goes from ON to OFF.

module userInput (clock, reset, in, out);

	output logic 	out;
	input logic 	in, clock, reset;

	// State variables
	enum { pressed, unpressed} ps, ns;

	// Next State logic
	always_comb begin
		case (ps)
			pressed:  	if (in)		ns = pressed;
							else 			ns = unpressed;
			
			unpressed:	if (in) 		ns = pressed;
							else 			ns = unpressed;
		endcase
	end

	// Output logic - could also be another always_comb block.
	assign out = (ps == pressed & ns == unpressed);
	
	// DFFs that move ps to ns or unpressed when reset
	always_ff @(posedge clock) begin
	if (reset) 
		ps <= unpressed;
	else
		ps <= ns;
	end
endmodule 

// userInput_testbench is used to test the functionality
// of the userInput module above. This is done by testing
// a few different input scenarios in which the time that
// the input signal in is ON for ranges from a low to high
// amount of clock cycles

module userInput_testbench();
 logic clk, reset, in;
 logic out;

 userInput dut (clk, reset, in, out);

 // Set up a simulated clock.
 parameter CLOCK_PERIOD=100;
 initial begin
	clk <= 0;
	forever #(CLOCK_PERIOD/2) clk <= ~clk; // Forever toggle the clock
 end

 // Set up the inputs to the design. Each line is a clock cycle.
 initial begin
							@(posedge clk);
 reset <= 1; 			@(posedge clk); // Always reset FSMs at start
 reset <= 0; in <= 0;@(posedge clk);
							@(posedge clk);
				 in <= 1;@(posedge clk);
				 			@(posedge clk);// only one press, even if holding
				 			@(posedge clk);
				 			@(posedge clk);							
				 in <= 0;@(posedge clk);
				 			@(posedge clk);
							@(posedge clk);
							@(posedge clk);
				 in <= 1;@(posedge clk);
							@(posedge clk);
				 in <= 0;@(posedge clk);
							@(posedge clk);				 
				 in <= 1;@(posedge clk);				 
							@(posedge clk);
				 in <= 0;@(posedge clk);			
							@(posedge clk);


	$stop; // End the simulation.
 end
endmodule 