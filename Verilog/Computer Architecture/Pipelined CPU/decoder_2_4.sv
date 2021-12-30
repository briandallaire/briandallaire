// Brian Dallaire
// 12/3/2021
// EE 469
// Lab #4

// decoder_2_4 takes the 1-bit input RegWrite and the 2-bit input select and outputs the 4-bit output enabler. 
// The purpose of this module is to represent a 2:4 decoder where there are 2 select inputs, 1 enable input, 
// and 4 outputs by using basic gates. The decoder will always output a 0 if RegWrite is 0. 

`timescale 1ps/1ps

module decoder_2_4 (RegWrite, select, enabler);
	
	//  enable bit for this particular decoder
	input logic RegWrite;
	
	input logic [1:0] select;  
	
	//  sends enable bits to the other 3:8 decoders
	output logic [3:0] enabler; 
	
	// used to represent inverted select bits
	logic notS0, notS1;
	
	// implements inverter gates to invert select bits
	not #50 notGate1 (notS0, select[0]);
	not #50 notGate2 (notS1, select[1]);
	
	// implements AND gates
	and #50 andGate1 (enabler[0], notS1, notS0, RegWrite);
	and #50 andGate2 (enabler[1], notS1, select[0], RegWrite);
	and #50 andGate3 (enabler[2], select[1], notS0, RegWrite);
	and #50 andGate4 (enabler[3], select[1], select[0], RegWrite);
	
endmodule 

// decoder_2_4_testbench tests for all relevant behaviors of a 2:4 decoder. Here I tested for every possibility
// since there aren't many in a 2:4 decoder. All combinations of the select bits have been tested. 
module decoder_2_4_testbench();

	logic RegWrite;
	logic [1:0] select;
	logic [3:0] enabler;
	
	decoder_2_4 dut (.RegWrite, .select, .enabler);
	
	initial begin
	
	RegWrite = 0; select = 2'b00; #500;
											#500;  
	RegWrite = 1; select = 2'b00; #500;
											#500;
	RegWrite = 0; select = 2'b01; #500;
											#500;
	RegWrite = 1; select = 2'b01; #500;
											#500;
	RegWrite = 0; select = 2'b10; #500;
											#500;
	RegWrite = 1; select = 2'b10; #500;
											#500;
	RegWrite = 0; select = 2'b11; #500;
											#500;
	RegWrite = 1; select = 2'b11; #500;
											#500;
	
	$stop;
	
	end 
	
endmodule 