// Brian Dallaire
// 11/12/2021
// EE 469
// Lab #3

// alu takes the 64-bit inputs A and B and the 3-bit input cntrl and outputs the 64-bit
// output result and the 1-bit outputs negative, zero, overflow, and carry_out. The purpose
// of this module is to represent the total 64-bit ALU that performs the operations the 
// stimulus file asked for. It uses the cntrl bits to determine the operation and performs
// the operation on A and B and outputs it through result. The 1-bit outputs represents 
// other information that may be useful, such as if the value is negative or a zero.  

`timescale 1ps/1ps

module alu (A, B, cntrl, result, negative, zero, overflow, carry_out);

	input logic		[63:0]	A, B;
	input logic		[2:0]		cntrl;
	output logic		[63:0]	result;
	output logic					negative, zero, overflow, carry_out;
	
	// implements the total 64-bit ALU module
	ALU_64 wideALU (.A(A), .B(B), .control(cntrl), .carry_out(carry_out), .negative(negative),
						 .overflow(overflow), .zero(zero), .ALU_outputBus(result));
	
	
	
endmodule 