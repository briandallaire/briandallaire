// Brian Dallaire
// 12/3/2021
// EE 469
// Lab #4

// ID_EX_Reg takes the 1-bit inputs clk, reset, MemWrite, MemRead, RegWrite, setflags, and LorR and
// the 2-bit inputs ALUSrc and MemtoReg and the 3-bit input ALU_Op and the 5-bit input Rd_ID and the
// 6-bit input shamt and the 64-bit inputs RF_outA, RF_outB, extendImm12, and extendD9 and outputs the
// 1-bit outputs MemWrite_IDEX, MemRead_IDEX, RegWrite_IDEX, setflags_IDEX, and LR_EX and the 2-bit outputs
// ALUSrc_IDEX and Mem2Reg_IDEX and the 3-bit output ALUOp_IDEX and the 5-bit output Rd_EX and the 6-bit
// output shamt_EX and the 64-bit outputs EX_A, EX_B, Imm12Reg, and D9Reg. The purpose of this module is
// to represent the register that separates the ID stage and EX stage of the pipelined processor.

`timescale 1ps/1ps

module ID_EX_Reg (clk, reset, ALUSrc, ALU_Op, MemWrite, MemRead, MemtoReg, RegWrite, setflags, ALUSrc_IDEX, ALUOp_IDEX, MemWrite_IDEX,
						MemRead_IDEX, Mem2Reg_IDEX, RegWrite_IDEX, setflags_IDEX, RF_outA, RF_outB, EX_A, EX_B, Rd_ID, Rd_EX, extendImm12,
						extendD9, Imm12Reg, D9Reg, LorR, LR_EX, shamt, shamt_EX);
						
	input logic clk, reset, MemWrite, MemRead, RegWrite, setflags, LorR;
	input logic [1:0] ALUSrc, MemtoReg;
	input logic [2:0] ALU_Op;
	input logic [4:0] Rd_ID;
	input logic [5:0] shamt;
	input logic [63:0] RF_outA, RF_outB, extendImm12, extendD9;
	
	output logic MemWrite_IDEX, MemRead_IDEX, RegWrite_IDEX, setflags_IDEX, LR_EX;
	output logic [1:0] ALUSrc_IDEX, Mem2Reg_IDEX;
	output logic [2:0] ALUOp_IDEX;
	output logic [4:0] Rd_EX;
	output logic [5:0] shamt_EX;
	output logic [63:0] EX_A, EX_B, Imm12Reg, D9Reg;
	
	D_FF MWr (.q(MemWrite_IDEX), .d(MemWrite), .reset, .clk);
	D_FF MRd (.q(MemRead_IDEX), .d(MemRead), .reset, .clk);
	D_FF RWr (.q(RegWrite_IDEX), .d(RegWrite), .reset, .clk);
	D_FF SFL (.q(setflags_IDEX), .d(setflags), .reset, .clk);
	D_FF LOR (.q(LR_EX), .d(LorR), .reset, .clk);
	
	varSize_D_FF #(.WIDTH(2))  ALUSrcReg (.clk, .reset, .d_in(ALUSrc), .q_out(ALUSrc_IDEX));
	varSize_D_FF #(.WIDTH(2))  M2R 	    (.clk, .reset, .d_in(MemtoReg), .q_out(Mem2Reg_IDEX));
	varSize_D_FF #(.WIDTH(3))  ALUOpReg  (.clk, .reset, .d_in(ALU_Op), .q_out(ALUOp_IDEX));
	varSize_D_FF #(.WIDTH(5))  RD  	    (.clk, .reset, .d_in(Rd_ID), .q_out(Rd_EX));
	varSize_D_FF #(.WIDTH(6))  SHamt     (.clk, .reset, .d_in(shamt), .q_out(shamt_EX));
	varSize_D_FF #(.WIDTH(64)) RFA 	    (.clk, .reset, .d_in(RF_outA), .q_out(EX_A));
	varSize_D_FF #(.WIDTH(64)) RFB 	    (.clk, .reset, .d_in(RF_outB), .q_out(EX_B));
	varSize_D_FF #(.WIDTH(64)) I12 	    (.clk, .reset, .d_in(extendImm12), .q_out(Imm12Reg));
	varSize_D_FF #(.WIDTH(64)) D9  	    (.clk, .reset, .d_in(extendD9), .q_out(D9Reg));


endmodule 

// ID_EX_Reg_testbench tests whether the registers all work properly for all inputs and outputs.

module ID_EX_Reg_testbench();

	logic clk, reset, MemWrite, MemRead, RegWrite, setflags, LorR;
	logic [1:0] ALUSrc, MemtoReg;
	logic [2:0] ALU_Op;
	logic [4:0] Rd_ID;
	logic [5:0] shamt;
	logic [63:0] RF_outA, RF_outB, extendImm12, extendD9;
	
	logic MemWrite_IDEX, MemRead_IDEX, RegWrite_IDEX, setflags_IDEX, LR_EX;
	logic [1:0] ALUSrc_IDEX, Mem2Reg_IDEX;
	logic [2:0] ALUOp_IDEX;
	logic [4:0] Rd_EX;
	logic [5:0] shamt_EX;
	logic [63:0] EX_A, EX_B, Imm12Reg, D9Reg;
	
	ID_EX_Reg dut (.clk, .reset, .ALUSrc, .ALU_Op, .MemWrite, .MemRead, .MemtoReg, .RegWrite, .setflags, .ALUSrc_IDEX, .ALUOp_IDEX, .MemWrite_IDEX,
						 .MemRead_IDEX, .Mem2Reg_IDEX, .RegWrite_IDEX, .setflags_IDEX, .RF_outA, .RF_outB, .EX_A, .EX_B, .Rd_ID, .Rd_EX, .extendImm12,
						 .extendD9, .Imm12Reg, .D9Reg, .LorR, .LR_EX, .shamt, .shamt_EX);
	
	parameter CLOCK_PERIOD = 100;
	
	initial begin 
		clk <= 0;
		forever #(CLOCK_PERIOD/2) clk <= ~clk;
	end
	
	initial begin 
		reset <= 1;	@(posedge clk);
		reset <= 0; MemWrite <= 0; MemRead <= 0; RegWrite <= 0; setflags <= 0; LorR <= 0; 
						ALUSrc <= 2'b00; MemtoReg <= 2'b00; ALU_Op <= 3'b000; Rd_ID <= 5'b00000; shamt <= 6'b000000;
						RF_outA <= 64'd0; RF_outB <= 64'd0; extendImm12 <= 64'd0; extendD9 <= 64'd0; repeat (2) @(posedge clk);
						
						MemWrite <= 1; MemRead <= 1; RegWrite <= 1; setflags <= 1; LorR <= 1; 
						ALUSrc <= 2'b11; MemtoReg <= 2'b11; ALU_Op <= 3'b010; Rd_ID <= 5'b01100; shamt <= 6'b001100;
						RF_outA <= 64'd69; RF_outB <= 64'd69; extendImm12 <= 64'd69; extendD9 <= 64'd69; repeat (2) @(posedge clk);
						
						MemWrite <= 0; MemRead <= 0; RegWrite <= 0; setflags <= 0; LorR <= 0; 
						ALUSrc <= 2'b00; MemtoReg <= 2'b00; ALU_Op <= 3'b000; Rd_ID <= 5'b00000; shamt <= 6'b000000;
						RF_outA <= 64'd0; RF_outB <= 64'd0; extendImm12 <= 64'd0; extendD9 <= 64'd0; repeat (2) @(posedge clk);
						
		$stop;
	end


endmodule 