// Brian Dallaire
// 10/15/2021
// EE 469
// Lab #1

// mux_32_1 takes the 5-bit input select_read, the 32-bit input input_read, and outputs the 1-bit output output_read.
// The purpose of this module is to use the select bits to output one out of the 32 total inputs of the mux.
// It uses ten 4:1 muxes and one 2:1 mux to replicate the effects of a 32:1 mux.  


`timescale 1ps/1ps

module mux_32_1 (select_read, input_read, output_read);
	
	input logic  [4:0]  select_read;
	input logic  [31:0] input_read;
	output logic 		  output_read;
	
	// used to connect outputs of the first row of muxes to second
	logic [7:0] frst_lvl_output;
	// used to connect outputs of the second row of muxes to the last mux
	logic [1:0] scnd_lvl_output;
	
	// first row 4:1 muxes consisting of eight muxes total. Outputs of each mux go into next row of muxes. 
	// This row takes the select bits select_read[1:0] and all 32 bits of input_read are split amongst the
	// eight muxes in order. 
	mux_4_1 mux1 (.inputSelect(select_read[1:0]), .loadbits(input_read[3:0]), .outData(frst_lvl_output[0]));
	mux_4_1 mux2 (.inputSelect(select_read[1:0]), .loadbits(input_read[7:4]), .outData(frst_lvl_output[1]));
	mux_4_1 mux3 (.inputSelect(select_read[1:0]), .loadbits(input_read[11:8]), .outData(frst_lvl_output[2]));
	mux_4_1 mux4 (.inputSelect(select_read[1:0]), .loadbits(input_read[15:12]), .outData(frst_lvl_output[3]));
	mux_4_1 mux5 (.inputSelect(select_read[1:0]), .loadbits(input_read[19:16]), .outData(frst_lvl_output[4]));
	mux_4_1 mux6 (.inputSelect(select_read[1:0]), .loadbits(input_read[23:20]), .outData(frst_lvl_output[5]));
	mux_4_1 mux7 (.inputSelect(select_read[1:0]), .loadbits(input_read[27:24]), .outData(frst_lvl_output[6]));
	mux_4_1 mux8 (.inputSelect(select_read[1:0]), .loadbits(input_read[31:28]), .outData(frst_lvl_output[7]));
	
	// second row of 4:1 muxes consisting of two muxes total. Outputs of each mux go into final mux. This row takes
	// select bits select_read[1:0] and all 8-bits of output from the first row that are split amongst the two muxes in order
	mux_4_1 mux9  (.inputSelect(select_read[3:2]), .loadbits(frst_lvl_output[3:0]), .outData(scnd_lvl_output[0]));
	mux_4_1 mux10 (.inputSelect(select_read[3:2]), .loadbits(frst_lvl_output[7:4]), .outData(scnd_lvl_output[1]));
	
	// last row consists of only one 2:1 mux. Uses the select bit select_read[4] and takes the 2-bits of output from the
	// second row. The output of this final mux is the output of the effective 32:1 mux.
	mux_2_1 mux11 (.select(select_read[4]), .load(scnd_lvl_output), .data(output_read)); 

	
	
endmodule 

// mux_32_1_testbench tests all the relevant behaviors of a 32:1 mux. Here I tested the extreme cases
// where the load bits are all 0, and where the load bits are all 1. I also tested an inbetween case
// where the load bits are random. For each case, I tested all possibilities of the select bits. 
module mux_32_1_testbench();

	logic   [4:0] select_read;
	logic  [31:0] input_read;
	logic 		  output_read;
	
	mux_32_1 dut (.select_read, .input_read, .output_read);
	
	int i, j, k, l;
	
	initial begin
		for(i = 0; i < 2000; i++) begin
			for(j = 0; j < 32; j++) begin
			
				select_read <= j; input_read <= i; #1000;
				
			end 
		end
		
		for(k = 0; k < 32; k++) begin
			select_read <= k; input_read <= '1; #1000;
		end
		
		for(l = 0; l < 32; l++) begin
			select_read <= l; input_read <= 32'hFAFAFAFA; #1000;
		end
		
		
		
	end
endmodule 