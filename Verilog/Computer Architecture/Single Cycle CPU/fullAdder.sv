// Brian Dallaire
// 11/12/2021
// EE 469
// Lab #3

// fullAdder takes the 1-bit inputs A, B, and Cin and outputs the 1-bit outputs
// S and Cout. The purpose of this module is to replicate a fullAdder using
// basic logic gates. It determines the sum of A and B and the carry out bit. 

`timescale 1ps/1ps

module fullAdder (A, B, Cin, S, Cout);

	input logic A, B, Cin;
	output logic S, Cout;
	
	// used to connect gates together
	logic and1, and2, and3;
	
	// first row of gates for the carry out are all AND gates
	and #50 andGate1 (and1, A, Cin);
	and #50 andGate2 (and2, A, B);
	and #50 andGate3 (and3, B, Cin);
	
	// last row of gates is an OR gate that outputs carry out using
   //	previous outputs from AND gates
	or  #50 orGate1 (Cout, and1, and2, and3);
	
	// seperate XOR gate used to find the output S
	xor #50 (S, A, B, Cin);
	

endmodule 

// fullAdder_testbench tests both the expected and unexpected cases in this module. For this testbench
// I tested all combinations of the input bits A, B, and Cin. This way I can confirm if the module
// has expected behavior with all inputs possible.
module fullAdder_testbench();

	logic A, B, Cin;
	logic S, Cout;
	
	fullAdder dut (.A, .B, .Cin, .S, .Cout);
	
	int  i;
	
	initial begin 
		for(i = 0; i < 8; i++) begin
			A <= i[2];
			B <= i[1];
			Cin <= i[0]; #1000;
		end
		
		$stop;
	end
endmodule 
	
	
	