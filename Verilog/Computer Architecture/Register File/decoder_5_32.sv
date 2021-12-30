`timescale 1ps/1ps

module decoder_5_32 (RegWrite, WriteRegister, WriteEnable);

	input logic RegWrite;
	input logic [4:0] WriteRegister;
	output logic [31:0] WriteEnable;
	
	logic [3:0] enabler;
	
	assign WriteEnable[31] = 0;
	
	decoder_2_4 decode_enabler (.RegWrite, .select(WriteRegister[4:3]), .enabler);
	decoder_3_8 decoder1			(.enable(enabler[0]), .selectbits(WriteRegister[2:0]), .enable_reg(WriteEnable[7:0]));
	decoder_3_8 decoder2			(.enable(enabler[1]), .selectbits(WriteRegister[2:0]), .enable_reg(WriteEnable[15:8]));
	decoder_3_8 decoder3			(.enable(enabler[2]), .selectbits(WriteRegister[2:0]), .enable_reg(WriteEnable[23:16]));
	decoder_3_8 decoder4			(.enable(enabler[3]), .selectbits(WriteRegister[2:0]), .enable_reg(WriteEnable[31:24])); //double check this logic
	
endmodule 


module decoder_5_32_testbench();

	logic RegWrite;
	logic [4:0]  WriteRegister;
	logic [31:0] WriteEnable;
	
	
	decoder_5_32 dut (.RegWrite, .WriteRegister, .WriteEnable);
	
	initial begin
	
	RegWrite = 0; WriteRegister = 5'b00000; #50;
														 #100;
	RegWrite = 1; WriteRegister = 5'b00000; #50;
														 #100;
	RegWrite = 0; WriteRegister = 5'b00000; #50;
														 #100;
	RegWrite = 0; WriteRegister = 5'b11111; #50;
														 #100;
	RegWrite = 1; WriteRegister = 5'b11111; #50;
													  	 #100;
	RegWrite = 0; WriteRegister = 5'b11111; #50;
														 #100;
	RegWrite = 0; WriteRegister = 5'b11110; #50;
														 #100;
	RegWrite = 1; WriteRegister = 5'b11110; #50;
													  	 #100;
	RegWrite = 0; WriteRegister = 5'b11110; #50;
														 #100;
	RegWrite = 0; WriteRegister = 5'b10101; #50;
														 #100;
	RegWrite = 1; WriteRegister = 5'b10101; #50;
													  	 #100;
	RegWrite = 0; WriteRegister = 5'b10101; #50;
														 #100;
	$stop;
	
	end
endmodule
	
	
	