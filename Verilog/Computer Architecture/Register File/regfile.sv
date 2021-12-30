

`timescale 1ps/1ps

module regfile (ReadData1, ReadData2, WriteData, ReadRegister1, ReadRegister2, WriteRegister, RegWrite, clk);


	input logic 		RegWrite, clk;
	input logic [4:0] ReadRegister1, ReadRegister2, WriteRegister;
	input logic [63:0] WriteData;
	output logic [63:0] ReadData1, ReadData2;
	
	
	logic [31:0] WriteEnable;
	logic [31:0][63:0] read_list;
	logic [63:0][31:0] inputData;
	
	
	decoder_5_32 	decoder5x32 (.RegWrite, .WriteRegister, .WriteEnable);
	register_list  allRegist  (.clk, .reset(0), .WriteEnable, .WriteData, .read_list);
	alignRegisters srtdRegist(.read_list, .connctMux(inputData));
	mux_64x32_1  	RdData_1 (.ReadRegister(ReadRegister1), .inputData, .ReadData(ReadData1));
	mux_64x32_1    RdData_2	(.ReadRegister(ReadRegister2), .inputData, .ReadData(ReadData2));

	
endmodule
	
	