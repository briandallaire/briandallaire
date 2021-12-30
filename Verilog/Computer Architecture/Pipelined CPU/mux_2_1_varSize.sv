// Brian Dallaire
// 12/3/2021
// EE 469
// Lab #4

// mux_2_1_varSize takes the 1-bit input selectBit and the 2, n-bit wide input
// loadBits and outputs the n-bit wide output outBits. The purpose of this module
// is to make a nx2:1 mux that can mux together two loads that are wider than one bit.
// For example, if you need to mux two 64-bit inputs, simply set the WIDTH to 64 and
// use those two inputs. The output will be as if it were a 64x2:1 mux.

`timescale 1ps/1ps

module mux_2_1_varSize #(parameter WIDTH = 1) (selectBit, loadBits, outBits);

	input logic  selectBit;
	input logic  [1:0][WIDTH - 1 : 0] loadBits;
	output logic [WIDTH - 1 : 0] outBits;
	
	genvar i;
	
	generate
		for(i = 0; i < WIDTH; i++) begin : n_mux2_1
			mux_2_1 mux2_1_i (.select(selectBit), .load({loadBits[1][i], loadBits[0][i]}), .data(outBits[i]));
		end
	endgenerate
	
endmodule 

// mux_2_1_varSize_testbench tests for the relevant behaviors in this lab. In this
// testbench, it tests multiple loads and sees if it outputs correct behavior based
// on the input selectBit.

module mux_2_1_varSize_testbench();

	logic  selectBit;
	logic  [1:0][5 : 0] loadBits;
	logic  [5 : 0] outBits;
	
	mux_2_1_varSize #(.WIDTH(6)) dut (.selectBit, .loadBits, .outBits);
	
	initial begin 
	
		loadBits <= {6'd40, 6'd24}; selectBit <= 0; #10000;
		loadBits <= {6'd40, 6'd24}; selectBit <= 1; #10000;
		loadBits <= {6'd24, 6'd40}; selectBit <= 0; #10000;
		loadBits <= {6'd24, 6'd40}; selectBit <= 1; #10000;
		loadBits <= {6'd20, 6'd32}; selectBit <= 0; #10000;
		loadBits <= {6'd20, 6'd32}; selectBit <= 1; #10000;
		
		$stop;
	end
endmodule 

