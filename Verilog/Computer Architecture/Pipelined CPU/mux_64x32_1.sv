// Brian Dallaire
// 12/3/2021
// EE 469
// Lab #4

// mux_64x32_1 takes the 5-bit input ReadRegister and 64, 32-bit inputs inputData and outputs the 
// 64-bit output ReadData. The purpose of this module is to do 64 iterations of a 32x1 mux to fully
// represent one of the 64x32:1 multiplexors present in the 32 by 64 ARM register file. 

`timescale 1ps/1ps
module mux_64x32_1 (ReadRegister, inputData, ReadData);
	
	input logic  [4:0] ReadRegister;
	input logic  [63:0][31:0] inputData;
	output logic [63:0] ReadData;
	
	// this generate statement implements a 32:1 mux 64 times. It takes one bit from each register from the same location
	// within each register and puts them into a 32:1 mux. Doing this 64 times effectively multiplexes 32, 64-bit inputs and
	// outputs a 64-bit output, which aligns with the lab criteria. 
	genvar i;
	generate
		for(i = 0; i < 64; i++) begin : largemux
			mux_32_1 mux32_1_i (.select_read(ReadRegister), .input_read(inputData[i]), .output_read(ReadData[i]));
		end
	endgenerate

endmodule 

// mux_64x32_1_testbench tests for a variety of relevant behavior. In this testbench
// I designed a quick nested for loop to cover a good amount of registers being selected 
// properly. 

module mux_64x32_1_testbench();

	logic  [4:0]        ReadRegister;
	logic  [63:0][31:0] inputData;
	logic  [63:0] 		  ReadData;
	
	mux_64x32_1 dut (.ReadRegister, .inputData, .ReadData);
	
	int i, j;
	
	initial begin 
		
		ReadRegister = 5'b00000;
		
		repeat(4) begin
		
			
			for(j = 0; j < 5; j++) begin
				for(i = 0; i < 64; i++) begin
					inputData[i][j] = i[j];
				end
			end	
		ReadRegister = ReadRegister + 1'b1; #10000;
		
		end
	
	$stop;
	end
endmodule 