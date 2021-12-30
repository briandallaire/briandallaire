// Brian Dallaire
// 10/29/2021
// EE 469
// Lab #2

// mux_8_1 takes the 3-bit input selectBits, the 8-bit input inputs, and outputs the 1-bit output muxOut.
// The purpose of this module is to use the select bits to output one out of the 8 total inputs of the mux.
// It uses basic gates to represent a 8:1 mux where there are 8 inputs and one output.

`timescale 1ps/1ps

module mux_8_1 (selectBits, inputs, muxOut);

	input logic  [2:0] selectBits;
	input logic  [7:0] inputs;
	output logic muxOut;
	
	// used to connect muxes together
	logic muxout1, muxout2;
	
	// first row of 4:1 muxes consisting of two muxes total. Outputs of each mux go into next row of muxes. 
	// This row takes the select bits selectBits[1:0] and all 8 bits of the input are split amongst the
	// two muxes in order. 
	mux_4_1 mux1 (.inputSelect(selectBits[1:0]), .loadbits(inputs[3:0]), .outData(muxout1));
	mux_4_1 mux2 (.inputSelect(selectBits[1:0]), .loadbits(inputs[7:4]), .outData(muxout2));
	
	// last row consists of only one 2:1 mux. Uses the select bit selectBits[2] and takes the 2-bits of output from the
	// first row. The output of this final mux is muxOut wich is the output of the effective 8:1 mux.
	mux_2_1 mux3 (.select(selectBits[2]), .load({muxout2, muxout1}), .data(muxOut));

	
endmodule 

// mux_8_1_testbench tests all the relevant behaviors of a 8:1 mux. Here I tested if the behavior between
// each row of muxes worked properly. Because this mux is made entirely of 2:1 and 4:1 muxes, this was the
// behavior that needed to be tested the most.
module mux_8_1_testbench();

	logic [2:0] selectBits;
	logic [7:0] inputs;
	logic 	   muxOut;
	
	mux_8_1 dut (.selectBits, .inputs, .muxOut);
	
	int i, k;
	initial begin 
	
	inputs = 8'b01111101;	#50;
	for(i = 0; i < 8; i++) begin
		selectBits[0] = i[0];
		selectBits[1] = i[1]; 
		selectBits[2] = i[2]; #2000;
	end
	
	
	inputs = 8'b10101010; #50;
	for(k = 0; k < 8; k++) begin
		selectBits[0] = k[0];
		selectBits[1] = k[1]; 
		selectBits[2] = k[2]; #2000;
	end
	
	$stop;
	end
endmodule 
	
	