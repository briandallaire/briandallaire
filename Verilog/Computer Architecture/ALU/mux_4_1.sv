// Brian Dallaire
// 10/29/2021
// EE 469
// Lab #2

// mux_4_1 takes the 2-bit input inputSelect, the 4-bit input loadbits, and outputs the 1-bit output outData.
// The purpose of this module is to use the select bits to output one out of the 4 total inputs of the mux.
// It uses basic gates to represent a 4:1 mux where there are 4 inputs and one output.

`timescale 1ps/1ps

module mux_4_1 (inputSelect, loadbits, outData);

	input logic [1:0] inputSelect;
	input logic [3:0] loadbits;
	output logic outData;
	
	// used to connect gates together
	logic notS1, notS0, and1, and2, and3, and4;
	
	// implement inverter gates to invert select bits
	not #50 notGate1 (notS1, inputSelect[1]);
	not #50 notGate2 (notS0, inputSelect[0]);
	
	// implementation of AND gates
	and #50 andGate1 (and1, notS1, notS0, loadbits[0]);
	and #50 andGate2 (and2, notS1, inputSelect[0], loadbits[1]);
	and #50 andGate3 (and3, inputSelect[1], notS0, loadbits[2]);
	and #50 andGate4 (and4, inputSelect[1], inputSelect[0], loadbits[3]);
	
	// implementation of OR gate outputting outData
	or #50 orGate1   (outData, and1, and2, and3, and4);
	
endmodule 


// mux_4_1_testbench tests all the relevant behaviors of a 4:1 mux. Here I tested the extreme cases
// where the load bits are all 0, and where the load bits are all 1. I also tested an inbetween case
// where the load bits are random. For each case, I tested all possibilities of the select bits.
module mux_4_1_testbench();

	logic [1:0] inputSelect;
	logic [3:0] loadbits;
	logic outData;
	
	mux_4_1 dut (.inputSelect, .loadbits, .outData);
	
	initial begin
	
	inputSelect = 2'b00; loadbits = 4'b0000; #150;
														  #50;
	inputSelect = 2'b01; loadbits = 4'b0000; #150;
														  #50;
	inputSelect = 2'b10; loadbits = 4'b0000; #150;
														  #50;
	inputSelect = 2'b11; loadbits = 4'b0000; #150;
														  #50;
	inputSelect = 2'b00; loadbits = 4'b0101; #150;
														  #50;	
	inputSelect = 2'b10; loadbits = 4'b0101; #150;
														  #50;
	inputSelect = 2'b11; loadbits = 4'b0101; #150;
														  #50;	
	inputSelect = 2'b01; loadbits = 4'b0101; #150;
														  #50;
	
	$stop;
	end
endmodule 