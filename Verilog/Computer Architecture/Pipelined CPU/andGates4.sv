// Brian Dallaire
// 12/3/2021
// EE 469
// Lab #4

// andGates4 takes the 16-bit input norOutputs and outputs the 4-bit output andOutputs.
// The purpose of this module is to take the outputs from the NOR gates and put them through
// four different AND gates. This preserves the information on if the value of the ALU output
// is a zero or not and sends the output to the next logic gates to determine the zero output

`timescale 1ps/1ps

module andGates4 (norOutputs, andOutputs);

	input logic [15:0] norOutputs;
	output logic [3:0] andOutputs;
	
	// this generate statement is used to process all 16-bits from the norOutputs through four and gates.
	// The end result outputs 4-bits which represents an output from each of the AND gates. 
	genvar j;
	generate
		for(j = 0; j < 16; j += 4) begin : allAnds
				and #50 andGates (andOutputs[j >> 2], norOutputs[j], norOutputs[j + 1], norOutputs[j + 2], norOutputs[j + 3]);
		end
	endgenerate

endmodule 	

// andGates4_testbench tests for the expected and unexpected behaviors that could occur in this lab. 
// For this testbench, I tested the extreme cases and a few cases inbetween. The case that matters most 
// is to see when norOutputs are all ones andOutputs outputs correctly.
module andGates4_testbench();

	logic [15:0] norOutputs;
	logic [3:0] andOutputs;
	
	andGates4 dut (.norOutputs, .andOutputs);
	
	initial begin 
	
	norOutputs = 16'h7FFF; #2000;
	norOutputs = 16'hAAAA; #2000;
	norOutputs = 16'h0000; #2000;
	norOutputs = 16'hFFFF; #2000;
	norOutputs = 16'h0001; #2000;
	
	end
	
endmodule 
	