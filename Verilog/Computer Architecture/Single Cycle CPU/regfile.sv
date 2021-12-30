// Brian Dallaire
// 11/12/2021
// EE 469
// Lab #3

// regfile takes the 1-bit inputs RegWrite and clk, 5-bit inputs ReadRegister1, ReadRegister2, and WriteRegister, and
// the 64-bit input WriteData, and the 64-bit outputs ReadData1, ReadData2. The purpose of this module is to represent
// the full 32 by 64 ARM register file. This 32 by 64 ARM register file is created using a 5:32 decoder, 32 registers 
// composed of D flip-flops, and two 64x32:1 multiplexors.  

`timescale 1ps/1ps

module regfile (ReadData1, ReadData2, WriteData, ReadRegister1, ReadRegister2, WriteRegister, RegWrite, clk);


	input logic 		RegWrite, clk;
	input logic [4:0] ReadRegister1, ReadRegister2, WriteRegister;
	input logic [63:0] WriteData;
	output logic [63:0] ReadData1, ReadData2;
	
	// represents outputs of the 5:32 decoder that act as enable signal for registers
	logic [31:0] WriteEnable;
	
	// represents all 32, 64-bit wide registers in the ARM register file
	logic [31:0][63:0] read_list;
	
	// transposition of read_list, used to connect individual bits of all 32 registers into
	// 64, 32:1 muxes. 
	logic [63:0][31:0] inputData;
	
	// decoder_5_32 takes the 1-bit input RegWrite, 5-bit input WriteRegister, and outputs the 32-bit
	// output Write Enable. This is the 5:32 decoder that outputs the enable signals for all 32 registers
	decoder_5_32 	decoder5x32 (.RegWrite, .WriteRegister, .WriteEnable);
	
	// register_list takes the 1-bit inputs clk and reset(0), and the 32-bit input WriteEnable and outputs
	// 32, 64-bit outputs read_list. This is the representation of all 32, 64-bit registers in the register file
	register_list  allRegist  (.clk, .reset(1'b0), .WriteEnable, .WriteData, .read_list);
	
	// alignRegisters takes the 32, 64-bit inputs read_list and outputs the 64, 32-bit outputs inputData. This
	// transposes read_list so that individual bits from all 32 registers can be used for the 64x31:1 multiplexor 
	alignRegisters srtdRegist(.read_list, .connctMux(inputData));
	
	// These mux_64x32_1 take the 5-bit input ReadRegister1/2, 64, 32-bit inputs inputData, and outputs the
	// 64-bit output ReadData1/2. These represent the two large 64x32:1 multiplexors that output ReadData 1 and 2. 
	mux_64x32_1  	RdData_1 (.ReadRegister(ReadRegister1), .inputData, .ReadData(ReadData1));
	mux_64x32_1    RdData_2	(.ReadRegister(ReadRegister2), .inputData, .ReadData(ReadData2));

	
endmodule
	
	