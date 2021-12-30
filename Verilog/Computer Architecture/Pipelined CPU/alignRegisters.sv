// Brian Dallaire
// 12/3/2021
// EE 469
// Lab #4

// alignRegisters takes 32, 64-bit inputs read_list and outputs 64, 32-bit outputs connctMux.
// The purpose of this module is to transpose the 2D array used to represent all 32, 64-bit registers
// in the 32 by 64 ARM register file. By transposing this array, we can access one individual bit
// from each register at a time, which is vital for forming the 64x32:1 multiplexor. 

`timescale 1ps/1ps

module alignRegisters (read_list, connctMux);

	input logic  [31:0][63:0] read_list;
	output logic [63:0][31:0] connctMux;
	
	// this generate statement takes read_list and inverts the rows and colums. It will output [j][k] 
	// instead of [k][j]. The assign is only used for wiring purposes.
	genvar j, k;
	generate
		for(j = 0; j < 64; j++) begin : regBit
			for(k = 0; k < 32; k++) begin : registerNum
				assign connctMux[j][k] = read_list[k][j];
			end
		end
	endgenerate 
	
endmodule 

// alignRegisters_testbench tests relevant behavior. In this testbench, I tested a 64-bit value in 5 or 6 of
// the registers and saw how it can realign them or transpose the bits in the output.

module alignRegisters_testbench();

	logic  [31:0][63:0] read_list;
	logic  [63:0][31:0] connctMux;
	
	alignRegisters dut (.read_list, .connctMux);
	
	int i, j;
	
	initial begin 
		
		for(i = 0; i < 6; i++) begin
			for(j = 0; j < 64; j++) begin
				read_list[i][j] = j[i]; 
			end
				#10000;
		end
		
		
	  
	
	$stop;
	end
	
endmodule 