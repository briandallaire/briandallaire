// Brian Dallaire
// 11/12/2021
// EE 469
// Lab #3

// ARM_SC_CPU takes in the 1-bit inputs clk and reset. The purpose of this module
// is to instantiate a single cycle CPU that can perform the instructions required
// from the spec. The single cycle CPU can perform instructions such as ADDI, 
// ADDS, SUBS, LDUR, STUR, B, B.LT, CBZ, MUL, LSL, and LSR.  


`timescale 1ps/1ps

module ARM_SC_CPU (clk, reset);
	
	input logic clk, reset;
	
	logic [63:0] Da, Db, Dw, Dout, PC_curr, PC_next, extendBr26, extendImm12, extendAd19, extendD9, shifted_val, mult_val, AddPC, AddBr, ALUout;
	logic [63:0] PC_IF_RF;
	logic [63:0] mult_valH;
   logic [63:0] muxALUSrc, muxBrType;
	logic [31:0] inst, instOut;
	logic [25:0] BrAddr26;
	logic [18:0] CondAddr19;
	logic [11:0] Imm12;
	logic [8:0] Daddr9;
	logic [5:0] shamt;
	logic [4:0] Rn, Rd, Rm;
	logic [4:0] muxAb;
	logic [3:0] xfer_size;
	logic [2:0] ALU_Op;																		// 3-bit control signal
	logic [1:0] ALUSrc, MemtoReg; 														// 2-bit control signals
	logic Reg2Loc, Branch, MemWrite, MemRead, RegWrite, UncondBr, setflags; // 1-bit control signals
	logic zero, negative, overflow, carry_out;  										// initial flag signals
	logic zeroReg, negativeReg, overflReg, carry_oReg; 							// flag registers to store previously set flags
	logic LorR;
	
	// labeling key components from 32-bit instruction
	assign Rn = inst[9:5];
	assign Rm = inst[20:16];
	assign Rd = inst[4:0];
	assign shamt = inst[15:10];
	
	assign BrAddr26 = inst[25:0]; // labels what is considered BrAddr26 (used in ___)
	//assign extendBr26 = 64'(signed'(BrAddr26)); // sign extends BrAddr26 to 64-bits
	assign extendBr26 = {{38{BrAddr26[25]}},BrAddr26}; // sign extend, which one should I use?
	
	assign CondAddr19 = inst[23:5]; // labels what is considered CondAddr19 (used in___)
	assign extendAd19 = 64'(signed'(CondAddr19)); // sign extends CondAddr19 to 64-bits
	
	assign Daddr9 = inst[20:12]; // labels what is considered Daddr9 (used in___)
	assign extendD9 = 64'(signed'(Daddr9)); // sign extends Daddr9 to 64-bits
	
	assign Imm12 = inst[21:10]; // labels what is considered Imm12 (used in I-type instructions)
	assign extendImm12 = {52'b0, Imm12}; // zero extends Imm12 to 64-bits
	
	// selects register Rd or Rm for the Ab input of the register file using a 64x2:1 mux. This
	// module takes in two 5-bit inputs Rm and Rd and the output determined by control signal 
	// Reg2Loc will go into the Ab (ReadRegister2) port of the register file
	mux_2_1_varSize #(.WIDTH(5))   muxRdRm (.selectBit(Reg2Loc), .loadBits({Rm, Rd}), .outBits(muxAb)); 
	
	// selects the input for the B input of the ALU. This is in effect a 64x4:1 mux that is deciding
	// between the sign extended Daddr9 value, the zero extended Imm12 value and Db. Since there are
	// only three inputs, I made the last empty slot just a 0 value input. 
   mux_4_1_varSize #(.WIDTH(64))  muxALUSr(.selectBits(ALUSrc), .inputBits({64'b0, extendImm12, extendD9, Db}), .dataBits(muxALUSrc));
	
	// selects the branch type between unconditional and conditional. This is in effect a 64x2:1 mux
	// that takes the sign extended values of BrAddr26 and CondAddr19. The output of this mux is determined
	// by the control signal Uncondbr and it decides which brach type has its address update the current PC value
	
	mux_2_1_varSize #(.WIDTH(64))  muxBrTp (.selectBit(UncondBr), .loadBits({extendBr26,extendAd19}), .outBits(muxBrType));
	
	// selects the next value that PC will be. This module is in effect a 64x2:1 mux that
	// takes the values (branch address + PC) or (PC + 4) and outputs one of them as the
	// 64-bit output PC_next
	
	mux_2_1_varSize #(.WIDTH(64))  muxBr   (.selectBit(Branch), .loadBits({AddBr, AddPC}), .outBits(PC_next));
	
	// selects the value being inputted into the write data port of the register file. This is in effect
	// a 64x4:1 mux that takes the values of the multiplication, the logical L or R shift, the output of
	// the datamemory, and the output of the ALU and decides on what 64-bit value goes into the port Dw.
	
	mux_4_1_varSize #(.WIDTH(64))  muxMtoR (.selectBits(MemtoReg), .inputBits({mult_val, shifted_val, Dout, ALUout}), .dataBits(Dw));
	
	
	// not gate used to determine left or right shift since !inst[21] = 1 is left and = 0 is right
	not #50 notGate1 (LorR, inst[21]); 
		
	// shifter for the shift instructions. Takes the 64-bit input and shifts it by
	// the amount determined by the shamt bits in either the left or right. The result
   // is a 64-bit value that is the result of the shift operation.
	
	shifter shift (.value(Da), .direction(LorR), .distance(shamt), .result(shifted_val));
	
	// mult for the multiplication instruction. It takes two 64-bit inputs and multiplies them
	// together. The result is a 128-bit output split into two 64-bit chunks. For this lab we are
	// using only the lower half of the total output.
	
	mult	multiply (.A(Da), .B(Db), .doSigned(1'b1), .mult_low(mult_val), .mult_high(mult_valH));
	
	

	
	// uses the control signal setflags to determine if the flag registers need to be updated or not. 
	// This module outputs the values of the flag registers that are used as conditions for certain
	// operations.
	
	flagRegisters setFlagRegs (.clk, .reset, .setflags, .zero, .negative, .overflow,
										.carry_out, .zeroReg, .negativeReg, .overflReg, .carry_oReg);

 

// *************************************************************************************************************//	
// 																IF Stage											 							 //
// *************************************************************************************************************//	

	// varSize_D_FF represents the program_counter in the CPU. This module takes the 64-bit input
	// PC_next and outputs the 64-bit output PC_curr. It is essentially just a 64-bit wide register
	
	varSize_D_FF #(.WIDTH(64)) PC (.clk, .reset, .d_in(PC_next), .q_out(PC_curr));
	
	// module instructmem takes the 64-bit value of the current PC and uses the PC to 
	// output a 32-bit instruction. 
	
	instructmem instruction_memory (.address(PC_curr), .instruction(inst), .clk);
	
	// this adder_64 module represents the adder between the hardwired "4" value and the current
	// PC value. The adder takes the current PC value and the value 4 and adds them together. The
	// output of this module is the sum of the two inputs.

	adder_64 PC_add (.inA(PC_curr), .inB(64'h0000000000000004), .addSum(AddPC));
	
	

// *************************************************************************************************************//	
// 																RF Stage													 					 //
// *************************************************************************************************************//	
	
	//IF_ID_REg(.clk, .reset, .PC_in(PC_curr), .PC_out(PC_IF_RF), .instr_in(inst), .instr_out(instOut));


	// regfile takes the 5-bit inputs Rn, muxAb (Rd or Rm), and Rd and RegWrite and the
	// 64-bit input Dw. The 5-bit inputs determine what registers are being read from
	// or being written into. The 64-bit input represents the data being written into
	// these registers. This module outputs two 64-bit outputs Da and Db.These values
	// represent the values within the registers they are being read from.

	regfile registerFile (.ReadData1(Da), .ReadData2(Db), .WriteData(Dw), .ReadRegister1(Rn), .ReadRegister2(muxAb),
								 .WriteRegister(Rd), .RegWrite, .clk);
								 
	// this adder_64 module represents the adder between the sign extended branch address (conditional 
	// or uncondtional) and the current PC value. The inputs of this module are the 64-bit current PC
	// value and the 64-bit sign extended branch address that is left shifted by 2. The output of this
	// module is the 64-bit sum of the two inputs. 

	adder_64 Br_add (.inA(PC_curr), .inB((muxBrType << 2)), .addSum(AddBr));
	
	
	// main_control takes the most significant 11 bits of the 32-bit instruction and
	// a few flags and uses these inputs to output control signals used throughout the CPU. 
	// These control signals control things like the muxes in order for the CPU to showcase
	// correct behavior for the instruction given.
	
	main_control controlUnit (.opcode_Instr(inst[31:21]), .zero, .negativeReg, .overflReg, .Reg2Loc, .ALUSrc, .MemtoReg,
									  .Branch, .MemWrite, .MemRead, .RegWrite, .UncondBr, .setflags, .ALUOp_bits(ALU_Op));
									  
	// [ADD FORWARDING UNIT HERE] F_U FU (foward A, forward B, Dest Reg, Dest Reg, RegWE, RegWE)
	
	
// *************************************************************************************************************//	
// 																Ex Stage													 					 //
// *************************************************************************************************************//	

	// ID_EX_Reg(ALUSrc, ALUOp, MEMWE, Mem2Reg, RegWE, ALUSrc_IDEX, ALUOp_IDEX, MemWE_IDEX, Mem2Reg_IDEX, RegWrite_IDEX);


	// alu is the module that represents the ALU unit in the CPU. This module takes the two 64-bit inputs
	// Da and muxALUSrc (Db or addresses being added) and outputs the 64-bit output ALUout and some flags
	// such as negative, zero, overflow, and carry_out. The result outputted is dependent on the control 
	// signals being inputted into the ALU. These control signals are determined using the main control module

	alu alu_unit (.A(Da), .B(muxALUSrc), .cntrl(ALU_Op), .result(ALUout), .negative, .zero, .overflow, .carry_out);
	
	

	
// *************************************************************************************************************//	
// 																MEM Stage												 					 //
// *************************************************************************************************************//	

	// EX_MEM_Reg();


	// datamem is the data memory unit of this CPU. It takes in a 64-bit address which is the output of the ALU. 
	// Depending on whether MemWrite is true or MemRead is true, it will write into memory or read from memeory.
	// The output of this module is a 64-bit output called Dout.

	datamem data_memory (.address(ALUout), .write_enable(MemWrite), .read_enable(MemRead), .write_data(Db), .clk,
								.xfer_size(4'd8), .read_data(Dout));


	
// *************************************************************************************************************//	
// 																WB Stage													 					 //
// *************************************************************************************************************//	

	// MEM_WR_Reg();
	
	// output of MEM_WR_Reg goes to write ports of Register File


endmodule 

// ARM_SC_CPU_testbench simply instantiates the ARM_SC_CPU module and runs it
// for 30 clock cycles. This gives it enough time to showcase that the ARM_SC_CPU
// is functioning properly for each benchmark. The clock period is made extremely
// long to ensure every instruction can be complete in one clock cycle. 
module ARM_SC_CPU_testbench();

	logic clk, reset;
	
	ARM_SC_CPU dut (.clk, .reset);
	
	parameter CLOCK_PERIOD = 1000000;
	
	initial begin 
		clk <= 0;
		forever #(CLOCK_PERIOD/2) clk <= ~clk;
	end
	
	initial begin 
		
		reset <= 1; @(posedge clk);
		reset <= 0; repeat(800) @(posedge clk);
		
		$stop;
	end
		
endmodule 
	
