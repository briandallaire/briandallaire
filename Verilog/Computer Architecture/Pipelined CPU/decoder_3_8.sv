// Brian Dallaire
// 12/3/2021
// EE 469
// Lab #4

// decoder_3_8 takes the 1-bit input enable and the 3-bit input selectbits and outputs the 8-bit output enable_reg. 
// The purpose of this module is to represent a 3:8 decoder where there are 3 select inputs, 1 enable input, 
// and 8 outputs by using basic gates. The decoder will always output a 0 if RegWrite is 0. 

`timescale 1ps/1ps

module decoder_3_8 (enable, selectbits, enable_reg);

	input logic enable;
	input logic [2:0] selectbits;
	output logic [7:0] enable_reg;
	
	// used to represent inverted select bits
	logic notS2, notS1, notS0;
	
	// implements inverter gates that invert select bits
	not #50 notGate1 (notS0, selectbits[0]);
	not #50 notGate2 (notS1, selectbits[1]);
	not #50 notGate3 (notS2, selectbits[2]);
	
	// implements AND gates
	and #50 andGate1 (enable_reg[0], notS2, notS1, notS0, enable);
	and #50 andGate2 (enable_reg[1], notS2, notS1, selectbits[0], enable);
	and #50 andGate3 (enable_reg[2], notS2, selectbits[1], notS0, enable);
	and #50 andGate4 (enable_reg[3], notS2, selectbits[1], selectbits[0], enable);
	and #50 andGate5 (enable_reg[4], selectbits[2], notS1, notS0, enable);
	and #50 andGate6 (enable_reg[5], selectbits[2], notS1, selectbits[0], enable);
	and #50 andGate7 (enable_reg[6], selectbits[2], selectbits[1], notS0, enable);
	and #50 andGate8 (enable_reg[7], selectbits[2], selectbits[1], selectbits[0], enable);
	
	
endmodule

// decoder_3_8_testbench tests for all relevant behaviors of a 3:8 decoder. Here I tested for every possibility
// since there aren't many in a 3:8 decoder. All combinations of the select bits have been tested with and without
// enable being true. 
module decoder_3_8_testbench();

	logic enable;
	logic [2:0] selectbits;
	logic [7:0] enable_reg;
	
	decoder_3_8 dut (.enable, .selectbits, .enable_reg);
	
	initial begin
	
	enable = 0; selectbits = 3'b000; #500;
											   #500;
	enable = 1; selectbits = 3'b000; #500;
											   #500;
	enable = 0; selectbits = 3'b001; #500;
											   #500;
	enable = 1; selectbits = 3'b001; #500;
											   #500;
	enable = 0; selectbits = 3'b010; #500;
											   #500;
	enable = 1; selectbits = 3'b010; #500;
											   #500;
	enable = 0; selectbits = 3'b011; #500;
											   #500;
	enable = 1; selectbits = 3'b011; #500;
											   #500;
	enable = 0; selectbits = 3'b100; #500;
											   #500;
	enable = 1; selectbits = 3'b100; #500;
											   #500;
	enable = 0; selectbits = 3'b101; #500;
											   #500;
	enable = 1; selectbits = 3'b101; #500;
											   #500;
	enable = 0; selectbits = 3'b110; #500;
											   #500;
	enable = 1; selectbits = 3'b110; #500;
											   #500;
	enable = 0; selectbits = 3'b111; #500;
											   #500;
	enable = 1; selectbits = 3'b111; #500;
											   #500;
	
	$stop;
	
	end 
	
endmodule 