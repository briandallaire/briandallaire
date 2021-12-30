// Brian Dallaire
// 12/3/2021
// EE 469
// Lab #4

// ARM_PL_CPU takes in the 1-bit inputs clk and reset. The purpose of this module
// is to instantiate a 5-stage pipelined CPU that can perform the instructions required.
// The pipelined CPU can perform instructions such as ADDI, ADDS, SUBS, LDUR, STUR, B,
// B.LT, CBZ, MUL, LSL, and LSR. It uses a forwarding unit to avoid most hazards and
// a branch delay slot is required to deal with branches (no stalling, no branch prediction). 


`timescale 1ps/1ps

module ARM_PL_CPU (clk, reset);
	
	input logic clk, reset;
	
	logic [63:0] Da, Db, Dw, Dout;
	logic [63:0] extendBr26, extendImm12, extendAd19, extendD9, Imm12Reg, D9Reg, AddBr;
	logic [63:0] PC_curr, PC_next, PC_IF_RF, AddPC;
	logic [63:0] ALUout, ALUoutMEM;
	logic [63:0] shifted_val, mult_val, mult_valH, shftOrMultAEX, fwrdvalEXA, fwrdvalEXB, mult_valMEM, shifted_valMEM;
   logic [63:0] muxALUSrc, muxBrType;
	logic [63:0] RF_outA, RF_outB, EX_A, EX_B, MEM_B, writeData;
	logic [31:0] inst, instOut;
	logic [25:0] BrAddr26;
	logic [18:0] CondAddr19;
	logic [15:0] norOuts;
	logic [11:0] Imm12;
	logic [8:0] Daddr9;
	logic [5:0] shamt, shamt_EX;
	logic [4:0] Rn, Rd, Rm;
	logic [4:0] Rd_ID, Rd_EX, Rd_MEM, Rd_WB;
	logic [4:0] muxAb;
	logic [3:0] xfer_size;
	logic [3:0] andOuts;
	logic [2:0] ALU_Op, ALUOp_IDEX;														// 3-bit control signal
	logic [1:0] ALUSrc, ALUSrc_IDEX, MemtoReg, Mem2Reg_IDEX, Mem2Reg_EXMEM; // 2-bit control signals
	logic [1:0] fwrdCntrl_A, fwrdCntrl_B; 												// 2-bit control signals for the forwarding muxes
	logic Reg2Loc, Branch, MemWrite, MemRead, RegWrite, UncondBr, setflags; 
	logic MemWrite_IDEX, MemRead_IDEX,  RegWrite_IDEX, setflags_IDEX,
		   MemWrite_EXMEM, MemRead_EXMEM, RegWrite_EXMEM, RegWrite_MEMWR;		// 1-bit control signals

	logic zero, negative, overflow, carry_out;  										// initial flag signals
	logic zeroReg, negativeReg, overflReg, carry_oReg; 							// flag registers to store previously set flags
	logic LorR, LR_EX; 																		// 1-bit signals for determining shift L or R
	logic notClk; 																				// inverted clock

	logic zero_out;																			// used for early CBZ detection
					 

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

	// selects the next value that PC will be. This module is in effect a 64x2:1 mux that
	// takes the values (branch address + PC) or (PC + 4) and outputs one of them as the
	// 64-bit output PC_next
	
	mux_2_1_varSize #(.WIDTH(64))  muxBr   (.selectBit(Branch), .loadBits({AddBr, AddPC}), .outBits(PC_next));	
	

// *************************************************************************************************************//	
// 																RF Stage													 					 //
// *************************************************************************************************************//	

	// IF_ID_Reg takes the current PC value and the instruction from instruction memory and outputs 
	// the value through a register. The purpose of this module is to represent the register separating
	// the IF and ID stage. 

	IF_ID_Reg IFID (.clk, .reset, .PC_in(PC_curr), .PC_out(PC_IF_RF), .instr_in(inst), .instr_out(instOut));

	// labeling key components from 32-bit instruction
	
	assign Rn = instOut[9:5];		 	// labels the first source register
	assign Rm = instOut[20:16];    	// labels the second source register
	assign Rd = instOut[4:0];		 	// labels the destination register
	assign shamt = instOut[15:10]; 	// labels the shift amount (used in R-type instructions)
	
	assign BrAddr26 = instOut[25:0]; 				 		// labels what is considered BrAddr26 (used in B-type instructions)
	//assign extendBr26 = 64'(signed'(BrAddr26)); 		// sign extends BrAddr26 to 64-bits
	assign extendBr26 = {{38{BrAddr26[25]}},BrAddr26}; // sign extend, doesn't matter which type
	
	assign CondAddr19 = instOut[23:5]; 				 // labels what is considered CondAddr19 (used in CB-type instructions)
	assign extendAd19 = 64'(signed'(CondAddr19)); // sign extends CondAddr19 to 64-bits
	
	assign Daddr9 = instOut[20:12]; 			 // labels what is considered Daddr9 (used in D-type instructions)
	assign extendD9 = 64'(signed'(Daddr9)); // sign extends Daddr9 to 64-bits
	
	assign Imm12 = instOut[21:10];		 // labels what is considered Imm12 (used in I-type instructions)
	assign extendImm12 = {52'b0, Imm12}; // zero extends Imm12 to 64-bits

	// not gate used to determine left or right shift since !inst[21] = 1 is left and = 0 is right
	not #50 notGate1 (LorR, instOut[21]); 
	
	
	// main_control takes the most significant 11 bits of the 32-bit instruction and
	// a few flags and uses these inputs to output control signals used throughout the CPU. 
	// These control signals control things like the muxes in order for the CPU to showcase
	// correct behavior for the instruction given.
	
	main_control controlUnit (.opcode_Instr(instOut[31:21]), .zero_out, .negative, .overflow, .negativeReg, .overflReg, .setflags_IDEX, .Reg2Loc, .ALUSrc, .MemtoReg,
									  .Branch, .MemWrite, .MemRead, .RegWrite, .UncondBr, .setflags, .ALUOp_bits(ALU_Op));									
	
	// fowardingUnit takes the 5-bit values address A (Rn) and address B (Rm or Rd) as well as the destination register and Regwrite signals 
	// from the Ex stage and MEM stage and the 2-bit ALUSrc control signal and outputs the 2-bit outputs that act as the control signals
	// for the forwarding muxes A and B. The main purpose of this module is to look at the current instruction and check for hazards. When
	// a hazard is found, it updates the forward control signal so that the forwarding mux outputs the correct value to account fot the hazard. 
	
	forwardingUnit F_U (.addrA(Rn), .addrB(muxAb), .instr(instOut), .Rd_EX, .Rd_MEM, .RegWrite_IDEX, .RegWrite_EXMEM, .fwrdCntrl_A, .fwrdCntrl_B, 
							  .ALUSrc);
	
	// selects the branch type between unconditional and conditional. This is in effect a 64x2:1 mux
	// that takes the sign extended values of BrAddr26 and CondAddr19. The output of this mux is determined
	// by the control signal Uncondbr and it decides which brach type has its address update the current PC value
	
	mux_2_1_varSize #(.WIDTH(64))  muxBrTp (.selectBit(UncondBr), .loadBits({extendBr26,extendAd19}), .outBits(muxBrType));
	
	// this adder_64 module represents the adder between the sign extended branch address (conditional 
	// or uncondtional) and the current PC value. The inputs of this module are the 64-bit current PC
	// value and the 64-bit sign extended branch address that is left shifted by 2. The output of this
	// module is the 64-bit sum of the two inputs. 

	adder_64 Br_target (.inA(PC_IF_RF), .inB((muxBrType << 2)), .addSum(AddBr));

	// selects register Rd or Rm for the Ab input of the register file using a 64x2:1 mux. This
	// module takes in two 5-bit inputs Rm and Rd and the output determined by control signal 
	// Reg2Loc will go into the Ab (ReadRegister2) port of the register file
	
	mux_2_1_varSize #(.WIDTH(5))   muxRdRm (.selectBit(Reg2Loc), .loadBits({Rm, Rd}), .outBits(muxAb)); 	

	// invClk takes the input clk and inverts it. The purpose of this gate is to create an 
	// inverted clock that will be used to resolve the WB and RF/ID hazard
	
	not #50 invClk (notClk, clk);
	
	// regfile takes the 5-bit inputs Rn, muxAb (Rd or Rm), and Rd and RegWrite and the
	// 64-bit input Dw. The 5-bit inputs determine what registers are being read from
	// or being written into. The 64-bit input represents the data being written into
	// these registers. This module outputs two 64-bit outputs Da and Db.These values
	// represent the values within the registers they are being read from.

	regfile registerFile (.ReadData1(Da), .ReadData2(Db), .WriteData(Dw), .ReadRegister1(Rn), .ReadRegister2(muxAb),
								 .WriteRegister(Rd_WB), .RegWrite(RegWrite_MEMWR), .clk(notClk)); 
								 
	// first level NOR gates to find if Db output is a zero. norGates16
	//	takes the 64-bit input Db and outputs the 16-bit output norOuts
	
	norGates16 norGates (.ALU_outs(RF_outB), .norOutputs(norOuts));
	
	// second level AND gates to find if Db output is a zero, andGates4 
	// takes the 16-bit input norOutputs and outputs the 4-bit output andOuts
	
	andGates4 andGates (.norOutputs(norOuts), .andOutputs(andOuts));
	
	// last level AND gate to find if Db output is a zero. This AND gate takes
	// the values from the previous AND gates to determine if the value is a zero
	// this output is used as the zero flag for the CBZ operation
	
	and #50 finalAnd (zero_out, andOuts[0], andOuts[1], andOuts[2], andOuts[3]);
	

	// selects whether the forwarded value should be the output of the mult function
	// or the output of the shift function from the EX stage. Mem2Reg_IDEX[0] is 0 when
	// it is the shift function and is 1 when it is the mult function. 	
	
	mux_2_1_varSize #(.WIDTH(64)) FwrdMoSAEX  (.selectBit(Mem2Reg_IDEX[0]), .loadBits({mult_val, shifted_val}), .outBits(shftOrMultAEX));

	// selects whether the forwarded A value should be the mult or shift value or the
	// output of the ALU from the EX stage. Mem2Reg_IDEX[1] is 0 when it uses the 
	// ALU output and 1 when it uses the mult or shift output
	
	mux_2_1_varSize #(.WIDTH(64)) FwrdEXA     (.selectBit(Mem2Reg_IDEX[1]), .loadBits({shftOrMultAEX, ALUout}), .outBits(fwrdvalEXA));
	
	// selects whether the forwarded B value should be the mult or shift value or the
	// output of the ALU from the EX stage. Mem2Reg_IDEX[1] is 0 when it uses the 
	// ALU output and 1 when it uses the mult or shift output

	mux_2_1_varSize #(.WIDTH(64)) FwrdEXB     (.selectBit(Mem2Reg_IDEX[1]), .loadBits({shftOrMultAEX, ALUout}), .outBits(fwrdvalEXB));
	
	// selects between the output of the register file, the forwarded value from the EX stage, and
	// the value being written into the register file. This mux is vital for the A port of the ALU 
	// in the EX stage as it determines what passes through into the ALU, mult function, and shift
	// functions. This is the fir forwarding mux that is controlled by the forwarding unit.

	mux_4_1_varSize #(.WIDTH(64)) muxFwrdA (.selectBits(fwrdCntrl_A), .inputBits({64'b0, fwrdvalEXA, writeData, Da}), .dataBits(RF_outA));
	
	// selects between the output of the register file, the forwarded value from the EX stage, and
	// the value being written into the register file. This mux is vital for the B port of the ALU 
	// in the EX stage as it determines what passes through into the ALU, mult function, and shift
	// functions. This is the forwarding mux that is controlled by the forwarding unit.
	
	mux_4_1_varSize #(.WIDTH(64)) muxFwrdB (.selectBits(fwrdCntrl_B), .inputBits({64'b0, fwrdvalEXB, writeData, Db}), .dataBits(RF_outB));

	
// *************************************************************************************************************//	
// 																Ex Stage													 					 //
// *************************************************************************************************************//	
	
	// ID_EX_Reg takes the control signals from the control unit as well as some other values such as
	// the extended immediate values, shift values, destination register addresses, and the output of
	// the forwarding muxes for both A and B. The purpose of this module is to act as the register
	// that separates the ID stage and the Ex stage. 
	
	ID_EX_Reg IDEX (.clk, .reset, .ALUSrc, .ALU_Op, .MemWrite, .MemRead, .MemtoReg, .RegWrite, .setflags, .ALUSrc_IDEX, .ALUOp_IDEX, .MemWrite_IDEX,
						 .MemRead_IDEX, .Mem2Reg_IDEX, .RegWrite_IDEX, .setflags_IDEX, .RF_outA, .RF_outB, .EX_A, .EX_B, .Rd_ID(Rd), .Rd_EX, .extendImm12,
						 .extendD9, .Imm12Reg, .D9Reg, .LorR, .LR_EX, .shamt, .shamt_EX);

		
	// shifter for the shift instructions. Takes the 64-bit input and shifts it by
	// the amount determined by the shamt bits in either the left or right. The result
   // is a 64-bit value that is the result of the shift operation.
	
	shifter shift (.value(EX_A), .direction(LR_EX), .distance(shamt_EX), .result(shifted_val));
	
	// mult for the multiplication instruction. It takes two 64-bit inputs and multiplies them
	// together. The result is a 128-bit output split into two 64-bit chunks. For this lab we are
	// using only the lower half of the total output.
	
	mult	multiply (.A(EX_A), .B(EX_B), .doSigned(1'b1), .mult_low(mult_val), .mult_high(mult_valH));
		
	// selects the input for the B input of the ALU. This is in effect a 64x4:1 mux that is deciding
	// between the sign extended Daddr9 value, the zero extended Imm12 value and Db. Since there are
	// only three inputs, I made the last empty slot just a 0 value input. 
	
	mux_4_1_varSize #(.WIDTH(64))  muxALUSr(.selectBits(ALUSrc_IDEX), .inputBits({64'b0, Imm12Reg, D9Reg, EX_B}), .dataBits(muxALUSrc));

	// alu is the module that represents the ALU unit in the CPU. This module takes the two 64-bit inputs
	// Da and muxALUSrc (Db or addresses being added) and outputs the 64-bit output ALUout and some flags
	// such as negative, zero, overflow, and carry_out. The result outputted is dependent on the control 
	// signals being inputted into the ALU. These control signals are determined using the main control module

	alu alu_unit (.A(EX_A), .B(muxALUSrc), .cntrl(ALUOp_IDEX), .result(ALUout), .negative, .zero, .overflow, .carry_out);
	
	// uses the control signal setflags to determine if the flag registers need to be updated or not. 
	// This module outputs the values of the flag registers that are used as conditions for certain
	// operations.
	
	flagRegisters setFlagRegs (.clk, .reset, .setflags(setflags_IDEX), .zero, .negative, .overflow,
										.carry_out, .zeroReg, .negativeReg, .overflReg, .carry_oReg);


// *************************************************************************************************************//	
// 																MEM Stage												 					 //
// *************************************************************************************************************//	

	// EX_MEM_Reg takes the control signals that haven't been used in the previous stage as well as other 
	// values such as the destination register from the previous stage, the multiplication function output,
	// the shift function output, and the ALU output. It takes these values and puts them through flip flop
	// registers. The purpose of this module is to separate the EX stage and the MEM stage. 

	EX_MEM_Reg EXMEM (.clk, .reset, .MemWrite_IDEX, .MemRead_IDEX, .Mem2Reg_IDEX, .RegWrite_IDEX, .setflags_IDEX,
							.MemWrite_EXMEM, .MemRead_EXMEM, .Mem2Reg_EXMEM, .RegWrite_EXMEM, .Rd_EX, .Rd_MEM, .ALUout,
							.ALUoutMEM, .EX_B, .MEM_B, .mult_val, .mult_valMEM, .shifted_val, .shifted_valMEM); 


	// datamem is the data memory unit of this CPU. It takes in a 64-bit address which is the output of the ALU. 
	// Depending on whether MemWrite is true or MemRead is true, it will write into memory or read from memeory.
	// The output of this module is a 64-bit output called Dout.

	datamem data_memory (.address(ALUoutMEM), .write_enable(MemWrite_EXMEM), .read_enable(MemRead_EXMEM), .write_data(MEM_B), .clk,
								.xfer_size(4'd8), .read_data(Dout));

	// selects the value being inputted into the write data port of the register file. This is in effect
	// a 64x4:1 mux that takes the values of the multiplication, the logical L or R shift, the output of
	// the datamemory, and the output of the ALU and decides on what 64-bit value goes into the port Dw.
	
	mux_4_1_varSize #(.WIDTH(64))  muxMtoR (.selectBits(Mem2Reg_EXMEM), .inputBits({mult_valMEM, shifted_valMEM, Dout, ALUoutMEM}), .dataBits(writeData));
	
// *************************************************************************************************************//	
// 																WB Stage													 					 //
// *************************************************************************************************************//	

	// MEM_WR_Reg takes the control signals not used in the previous stage as well as other signals such as
	// the destination register from the last stage and the mux output that decided between the ALU output, 
	// shift function output, mult function output, and datamemory output. The module outputs the signals
	// that goes to the write ports of Register File. The main purpose of this module is to separate the
	// MEM stage and the WR stage. 
	
	MEM_WR_Reg MEMWR (.clk, .reset, .RegWrite_EXMEM, .RegWrite_MEMWR, .Rd_MEM, .Rd_WB, .writeData, .Dw);

endmodule 

// ARM_PL_CPU_testbench simply instantiates the ARM_PL_CPU module and runs it
// for enough time to showcase that the ARM_PL_CPU is functioning properly for
// each benchmark. 
 
module ARM_PL_CPU_testbench();

	logic clk, reset;
	
	ARM_PL_CPU dut (.clk, .reset);
	
	parameter CLOCK_PERIOD = 500000;
	
	initial begin 
		clk <= 0;
		forever #(CLOCK_PERIOD/2) clk <= ~clk;
	end
	
	initial begin 
		
		reset <= 1; @(posedge clk);
		reset <= 0; repeat(700) @(posedge clk);
		
		$stop;
	end
		
endmodule 
	
