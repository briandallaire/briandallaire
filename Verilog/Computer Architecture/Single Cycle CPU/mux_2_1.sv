// Brian Dallaire
// 11/12/2021
// EE 469
// Lab #3

// mux_2_1 takes the 1-bit input select, the 2-bit input load, and outputs the 1-bit output data.
// the purpose of this module is to use the select bit to output either the least significant bit
// or the most significant bit of the 2-bit load. It uses basic gates to represent
// a 2:1 mux where there are 2 inputs and one output.  

`timescale 1ps/1ps

module mux_2_1 (select, load, data); 

	input logic select;
	input logic [1:0] load;
	output logic data;
	
	// used to link gates together
	logic notSelect, and1, and2;
	
	// inverter gate for select bit
	not #50 notS (notSelect, select);
	
	// implement AND gates
	and #50 andgate1 (and1, notSelect, load[0]);
	and #50 andgate2 (and2, select, load[1]);
	
	// implement OR gate and output data
	or  #50 or1  (data, and1, and2);
	
endmodule 

// mux_2_1_testbench tests all the relevant behaviors of a 2:1 mux. Here I tested the extreme cases
// where the load bits are all 0, and where the load bits are all 1. I also tested an inbetween case
// where the load bits are random. For each case, I tested all possibilities of the select bits. 	
	
module mux_2_1_testbench();

	logic select;
	logic [1:0] load;
	logic data;
	
	mux_2_1 dut (.select, .load, .data);
	
	initial begin
	
	select = 0; load = 2'b00; #1000;
	select = 1; load = 2'b00; #1000;
	select = 0; load = 2'b01; #1000;
	select = 1; load = 2'b01; #1000;
	select = 0; load = 2'b10; #1000;
	select = 1; load = 2'b10; #1000;
	select = 0; load = 2'b11; #1000;
	select = 1; load = 2'b11; #1000;
	
	$stop;
	end
endmodule 