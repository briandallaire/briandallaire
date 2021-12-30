// Brian Dallaire
// 12/3/2021
// EE 469
// Lab #4

// EX_MEM_Reg takes the 1-bit inputs clk, reset, MemWrite_IDEX, MemRead_IDEX, RegWrite_IDEX, and
// setflags_IDEX and the 2-bit input Mem2Reg_IDEX and the 5-bit input Rd_EX and the 64-bit input 
// ALUout, EX_B, mult_val, and shifted_val and outputs the 1=bit outputs MemWrite_EXMEM, MemRead_EXMEM,
// and RegWrite_EXMEM and the 2-bit output Mem2Reg_EXMEM and the 5-bit output Rd_MEM and the 64-bit
// outputs ALUoutMEM, MEM_B, mult_valMEM, and shifted_val MEM. The main purpose of this module is to
// represent the register that separates the EX stage and MEM stage in the pipelined processor. 

`timescale 1ps/1ps

module EX_MEM_Reg(clk, reset, MemWrite_IDEX, MemRead_IDEX, Mem2Reg_IDEX, RegWrite_IDEX, setflags_IDEX,
						MemWrite_EXMEM, MemRead_EXMEM, Mem2Reg_EXMEM, RegWrite_EXMEM, Rd_EX, Rd_MEM, ALUout,
						ALUoutMEM, EX_B, MEM_B, mult_val, mult_valMEM, shifted_val, shifted_valMEM);
						
	input logic clk, reset, MemWrite_IDEX, MemRead_IDEX, RegWrite_IDEX, setflags_IDEX;
	input logic [1:0] Mem2Reg_IDEX;
	input logic [4:0] Rd_EX;
	input logic [63:0] ALUout, EX_B, mult_val, shifted_val;
	
	output logic MemWrite_EXMEM, MemRead_EXMEM, RegWrite_EXMEM;
	output logic [1:0] Mem2Reg_EXMEM;
	output logic [4:0] Rd_MEM;
	output logic [63:0] ALUoutMEM, MEM_B, mult_valMEM, shifted_valMEM;
	
	D_FF MWr (.q(MemWrite_EXMEM), .d(MemWrite_IDEX), .reset, .clk);
	D_FF MRd (.q(MemRead_EXMEM), .d(MemRead_IDEX), .reset, .clk);
	D_FF RWr (.q(RegWrite_EXMEM), .d(RegWrite_IDEX), .reset, .clk);
	
	
	varSize_D_FF #(.WIDTH(2)) M2R (.clk, .reset, .d_in(Mem2Reg_IDEX), .q_out(Mem2Reg_EXMEM));
	varSize_D_FF #(.WIDTH(5)) RD  (.clk, .reset, .d_in(Rd_EX), .q_out(Rd_MEM));
	varSize_D_FF #(.WIDTH(64)) ALM (.clk, .reset, .d_in(ALUout), .q_out(ALUoutMEM));
	varSize_D_FF #(.WIDTH(64)) BMM (.clk, .reset, .d_in(EX_B), .q_out(MEM_B));
	varSize_D_FF #(.WIDTH(64)) MUL (.clk, .reset, .d_in(mult_val), .q_out(mult_valMEM));
	varSize_D_FF #(.WIDTH(64)) SFT (.clk, .reset, .d_in(shifted_val), .q_out(shifted_valMEM));

	
//	// uses the control signal setflags to determine if the flag registers need to be updated or not. 
//	// This module outputs the values of the flag registers that are used as conditions for certain
//	// operations.
//	
//	flagRegisters setFlagRegs (.clk, .reset, .setflags, .zero, .negative, .overflow,
//										.carry_out, .zeroReg, .negativeReg, .overflReg, .carry_oReg);

endmodule 

// EX_MEM_Reg_testbench tests whether the registers all work properly for all inputs and outputs.

module EX_MEM_Reg_testbench();

	logic clk, reset, MemWrite_IDEX, MemRead_IDEX, RegWrite_IDEX, setflags_IDEX;
	logic [1:0] Mem2Reg_IDEX;
	logic [4:0] Rd_EX;
	logic [63:0] ALUout, EX_B, mult_val, shifted_val;
	
	logic MemWrite_EXMEM, MemRead_EXMEM, RegWrite_EXMEM;
	logic [1:0] Mem2Reg_EXMEM;
	logic [4:0] Rd_MEM;
	logic [63:0] ALUoutMEM, MEM_B, mult_valMEM, shifted_valMEM;

	EX_MEM_Reg dut (.clk, .reset, .MemWrite_IDEX, .MemRead_IDEX, .Mem2Reg_IDEX, .RegWrite_IDEX, .setflags_IDEX,
						 .MemWrite_EXMEM, .MemRead_EXMEM, .Mem2Reg_EXMEM, .RegWrite_EXMEM, .Rd_EX, .Rd_MEM, .ALUout,
						 .ALUoutMEM, .EX_B, .MEM_B, .mult_val, .mult_valMEM, .shifted_val, .shifted_valMEM);

	parameter CLOCK_PERIOD = 100;
	
	initial begin 
		clk <= 0;
		forever #(CLOCK_PERIOD/2) clk <= ~clk;
	end

	initial begin 
		reset <= 1; @(posedge clk);
		reset <= 0; MemWrite_IDEX <= 0; MemRead_IDEX <= 0; RegWrite_IDEX <= 0; setflags_IDEX <= 0; Mem2Reg_IDEX <= 2'b00;
						Rd_EX <= 5'b00000; ALUout <= 64'd0; EX_B <= 64'd0; mult_val <= 64'd0; shifted_val <= 64'd0; repeat(2) @(posedge clk);
						
						MemWrite_IDEX <= 1; MemRead_IDEX <= 1; RegWrite_IDEX <= 1; setflags_IDEX <= 1; Mem2Reg_IDEX <= 2'b11;
						Rd_EX <= 5'b11111; ALUout <= 64'd3333; EX_B <= 64'd3333; mult_val <= 64'd3333; shifted_val <= 64'd3333; repeat(2) @(posedge clk);
						
						MemWrite_IDEX <= 0; MemRead_IDEX <= 0; RegWrite_IDEX <= 0; setflags_IDEX <= 0; Mem2Reg_IDEX <= 2'b00;
						Rd_EX <= 5'b00000; ALUout <= 64'd0; EX_B <= 64'd0; mult_val <= 64'd0; shifted_val <= 64'd0; repeat(2) @(posedge clk);
		
		$stop;
	end
	
endmodule 