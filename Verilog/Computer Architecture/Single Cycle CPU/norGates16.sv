// Brian Dallaire
// 11/12/2021
// EE 469
// Lab #3

// norGates16 takes the 64-bit input ALU_outs and outputs the 16-bit output norOutputs.
// The purpose of this module is to take the 64-bit input and put them through NOR gates
// 4 inputs at a time. This is the start of a chain of logic gates to replicate a 64-bit
// input NOR gate.

`timescale 1ps/1ps

module norGates16 (ALU_outs, norOutputs);

	input logic [63:0] ALU_outs;
	output logic [15:0] norOutputs;
	
	// this generate statement takes the 64-bit ALU output and puts them through 16 different
	// nor gates. Each bit of norOutputs represents the output from one of the NOR gates. 
	genvar k;
	generate 
		for(k = 0; k < 64; k += 4) begin : allNors
				nor #50 norGates (norOutputs[k >> 2], ALU_outs[k], ALU_outs[k + 1], ALU_outs[k + 2], ALU_outs[k + 3]);
		end
	endgenerate 
	
endmodule 

// norGates16_testbench tests for the expected and unexpected behaviors that could occur in this lab. 
// For this testbench, I tested both extremes and a few random values. The only important test is to
// see if it outputs properly when the inputs are all zero. 
module norGates16_testbench();

	logic [63:0] ALU_outs;
	logic [15:0] norOutputs;
	
	norGates16 dut (.ALU_outs, .norOutputs);
	
	initial begin 
	
	ALU_outs = 64'hAAAAAAAAAAAAAAAA; #2000;
	ALU_outs = 64'h0000000000000001; #2000;
	ALU_outs = 64'h0000000000000000; #2000;
	ALU_outs = 64'h0000010000000000; #2000;
	
	$stop;
	end
endmodule 