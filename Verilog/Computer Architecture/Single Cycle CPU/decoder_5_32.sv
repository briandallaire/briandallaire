// Brian Dallaire
// 11/12/2021
// EE 469
// Lab #3

// decoder_5_32 takes the 1-bit input RegWrite and the 5-bit input WriteRegister and outputs the 32-bit output WriteEnable. 
// The purpose of this module is to represent a 5:32 decoder where there are 5 select inputs, 1 enable input, 
// and 32 outputs by using simple gates. This 5:32 decoder in particular uses four 3:8 decoders and one 2:4 decoder to replicate
// the effects of a 5:32 decoder. This way, it satisfies the condition that there can only be up to four inputs into any gate since
// anything larger than a 3:8 decoder would require 5 input gates to create at a basic level (with the enable bit included). 
// The decoder will always output a 0 if RegWrite is 0. 


`timescale 1ps/1ps

module decoder_5_32 (RegWrite, WriteRegister, WriteEnable);

	input logic RegWrite;
	input logic [4:0] WriteRegister;
	output logic [31:0] WriteEnable;
	
	// connects 2:4 decoder to the four 3:8 decoders
	logic [3:0] enabler;
	
	// decoder_2_4 takes the 1-bit input RegWrite and 2-bit input WriteRegister[4:3] and outputs the 4b-bit output enabler. 
	// This 2:4 decoder acts as the enable signal distributor for the four 3:8 decoders it connects to. The outputs of this
	// 2:4 decoder are connected to the enable inputs of the four 3:8 decoders.
	decoder_2_4 decode_enabler (.RegWrite, .select(WriteRegister[4:3]), .enabler);
	
	// decoder_3_8 takes the 1-bit input enabler[0] and 3-bit inputs WriteRegister[2:0] and outputs the 8-bit output WriteEnable[7:0]
	// This 3:8 decoder represents the first 8 bits of the 32-bit output WriteEnable
	decoder_3_8 decoder1			(.enable(enabler[0]), .selectbits(WriteRegister[2:0]), .enable_reg(WriteEnable[7:0]));
	
	// decoder_3_8 takes the 1-bit input enabler[0] and 3-bit inputs WriteRegister[2:0] and outputs the 8-bit output WriteEnable[7:0]
	// This 3:8 decoder represents the first 8 bits of the 32-bit output WriteEnable
	decoder_3_8 decoder2			(.enable(enabler[1]), .selectbits(WriteRegister[2:0]), .enable_reg(WriteEnable[15:8]));
	
	// decoder_3_8 takes the 1-bit input enabler[0] and 3-bit inputs WriteRegister[2:0] and outputs the 8-bit output WriteEnable[7:0]
	// This 3:8 decoder represents the first 8 bits of the 32-bit output WriteEnable
	decoder_3_8 decoder3			(.enable(enabler[2]), .selectbits(WriteRegister[2:0]), .enable_reg(WriteEnable[23:16]));
	
	// decoder_3_8 takes the 1-bit input enabler[0] and 3-bit inputs WriteRegister[2:0] and outputs the 8-bit output WriteEnable[7:0]
	// This 3:8 decoder represents the first 8 bits of the 32-bit output WriteEnable
	decoder_3_8 decoder4			(.enable(enabler[3]), .selectbits(WriteRegister[2:0]), .enable_reg(WriteEnable[31:24])); 
	
endmodule 

// decoder_5_32_testbench tests for all relevant behaviors of a 5:32 decoder. Here I tested both extreme cases
// where the select bits are all 0 or all 1. I also tested inbetween cases where the select bits are random. 
// For each case, I tested with both RegWrite being true and false to confirm the decoder's behavior. 
module decoder_5_32_testbench();

	logic RegWrite;
	logic [4:0]  WriteRegister;
	logic [31:0] WriteEnable;
	
	
	decoder_5_32 dut (.RegWrite, .WriteRegister, .WriteEnable);
	
	initial begin
	
	RegWrite = 0; WriteRegister = 5'b00000; #500;
														 #500;
	RegWrite = 1; WriteRegister = 5'b00000; #500;
														 #500;
	RegWrite = 0; WriteRegister = 5'b00000; #500;
														 #500;
	RegWrite = 0; WriteRegister = 5'b11111; #500;
														 #500;
	RegWrite = 1; WriteRegister = 5'b11111; #500;
													  	 #500;
	RegWrite = 0; WriteRegister = 5'b11111; #500;
														 #500;
	RegWrite = 0; WriteRegister = 5'b11110; #500;
														 #500;
	RegWrite = 1; WriteRegister = 5'b11110; #500;
													  	 #500;
	RegWrite = 0; WriteRegister = 5'b11110; #500;
														 #500;
	RegWrite = 1; WriteRegister = 5'b11110; #500;
													  	 #500;
	RegWrite = 1; WriteRegister = 5'b11110; #500;
														 #500;
	RegWrite = 0; WriteRegister = 5'b10101; #500;
														 #500;
	RegWrite = 1; WriteRegister = 5'b10101; #500;
													  	 #500;
	RegWrite = 0; WriteRegister = 5'b10101; #500;
														 #500;
	$stop;
	
	end
endmodule
	
	
	