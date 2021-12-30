// Brian Dallaire
// 11/12/2021
// EE 469
// Lab #3

// mux_4_1_varSize takes the 2-bit input selectBits and the 4, n-bit wide input
// inputBits and outputs the n-bit wide output dataBits. The purpose of this module
// is to make a nx4:1 mux that can mux together four input loads that are wider than
// one bit. For example, if you need to mux four 64-bit inputs, simply set the WIDTH
// to 64 and use those four inputs. The output will be as if it were a 64x4:1 mux.

`timescale 1ps/1ps

module mux_4_1_varSize #(parameter WIDTH = 1) (selectBits, inputBits, dataBits);

	input logic  [1:0] selectBits;
	input logic  [3:0][WIDTH - 1 : 0] inputBits;
	output logic [WIDTH - 1 : 0] dataBits;
	
	genvar i;
	
	generate
		for(i = 0; i < WIDTH; i++) begin : n_mux2_1
			mux_4_1 mux4_1_i (.inputSelect(selectBits), .loadbits({inputBits[3][i], inputBits[2][i],
																					 inputBits[1][i], inputBits[0][i]}), .outData(dataBits[i]));
		end
	endgenerate
	
endmodule 

// mux_4_1_varSize_testbench tests for the relevant behaviors in this lab. In this
// testbench, it tests multiple loads and sees if it outputs correct behavior based
// on the input selectBits.

module mux_4_1_varSize_testbench();

	logic  [1:0] selectBits;
	logic  [3:0][1 : 0] inputBits;
	logic  [1 : 0] dataBits;
	
	mux_4_1_varSize #(.WIDTH(2)) dut (.selectBits, .inputBits, .dataBits);
	
	int i, j, k, l;
	
	initial begin 
		
		selectBits <= 2'b00;
		
		repeat(4) begin
		
		
		for(i = 0; i < 4; i++) begin
			for(j = 0; j < 4; j++) begin
				for(k = 0; k < 4; k++) begin
					for(l = 0; l < 4; l++) begin
						inputBits = {i[1:0], j[1:0], k[1:0], l[1:0]}; #10000;
					end
				end
			end
		end
		
		selectBits <= selectBits + 1'b1;
		
		end
		
		$stop;
	end
endmodule 
