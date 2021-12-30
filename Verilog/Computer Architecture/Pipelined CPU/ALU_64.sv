// Brian Dallaire
// 12/3/2021
// EE 469
// Lab #4

// ALU_64 takes the 64-bit inputs A and B and the 3-bit input control and outputs the
// 1-bit outputs carry_out, negative, overflow, and zero and the 64-bit output ALU_outputBus.
// The purpose of this module is to combine 64 instantiations of the bitslice ALU to replicate the
// behavior of a 64-bit ALU that performs the operations needed. I also used some of the outputs from
// the overall ALU to find outputs such as carry_out, negative, overflow, and zero. 

`timescale 1ps/1ps

module ALU_64(A, B, control, carry_out, negative, overflow, zero, ALU_outputBus);

	input logic [63:0] A, B;
	input logic [2:0] control;
	output logic carry_out, negative, overflow, zero;
	output logic [63:0] ALU_outputBus;
	
	// logic used to connect the carryouts between each bitslice ALU
	logic [63:0] c_out;
	
	// logic used to connect gates together when finding if ALU output is zero
	logic [15:0] norOuts;
	logic [3:0] andOuts;
	
	
	// this generate statement is used to instantiate the bitslice ALU 64 times. The first ALU is
	// an exception case since the carry in bit should be the least significant bit of the control
	// bits. This is also the bit used to determine if it is subtraction or not. This generate statement
	// will output 64 total bits as the ALU output of whatever operation that was decided by the select
	// bits. In addition, it will output 64 carry out bits where the last carry out is used as an output
	// and the last two are used to find overflow.
	genvar i;
	generate 

		bitALU alu_start (.Ain(A[0]), .Bin(B[0]), .Cin(control[0]), .select(control), .Cout(c_out[0]), .ALU_out(ALU_outputBus[0]));

		for(i = 1; i < 64; i++) begin : largeALU
			bitALU alu_i (.Ain(A[i]), .Bin(B[i]), .Cin(c_out[i-1]), .select(control),
							  .Cout(c_out[i]), .ALU_out(ALU_outputBus[i]));
		end
		

	endgenerate
	
	// first level NOR gates to find if ALU output is a zero. norGates16
	//	takes the 64-bit input ALU_outputBus and outputs the 16-bit output norOuts
	norGates16 norGates (.ALU_outs(ALU_outputBus), .norOutputs(norOuts));
	
	// second level AND gates to find if ALU output is a zero, andGates4 
	// takes the 16-bit input norOutputs and outputs the 4-bit output andOuts
	andGates4 andGates (.norOutputs(norOuts), .andOutputs(andOuts));
	
	// last level AND gate to find if ALU output is a zero. This AND gate takes
	// the values from the previous AND gates to determine if the value is a zero 
	and #50 finalAnd (zero, andOuts[0], andOuts[1], andOuts[2], andOuts[3]);
			
	
	// attach wire to the most significant bit of ALU output to determine if negative
	assign negative = ALU_outputBus[63];
	
	// find overflow by passing the last two carry out values into an XOR gate
	xor #50 xorGate (overflow, c_out[63], c_out[62]);
	
	// carry out is equivalent to the last carry out value
	assign carry_out = c_out[63];
	
endmodule 

// ALU_64_testbench tests multiple wanted behaviors from the lab. In this testbench,
// I test specific A and B values to see if addition and subtraction are working properly.
// I also test some A and B values to see if the overflow and zero signals work properly.

module ALU_64_testbench();

	logic [63:0] A, B;
	logic [2:0] control;
	logic carry_out, negative, overflow, zero;
	logic [63:0] ALU_outputBus;
	
	ALU_64 dut (.A, .B, .control, .carry_out, .negative, .overflow, .zero, .ALU_outputBus);
	
	int i;
	initial begin 
	
	A = 64'd300; B = 64'd250; #50; // tests for add and subtract
	//A = 64'd100; B = 64'd120; #50; // tests for negative and add and subtract
	//A = '1; B = 64'd9223372036854775808; #50; //tests for overflow
	//A = 64'd0; B = 64'd0; #50; // tests for zero
	
	for(i = 0; i < 8; i++) begin
		control[2] = i[2];
		control[1] = i[1];
		control[0] = i[0]; #8000;
	end

	
	$stop;
	end
endmodule 