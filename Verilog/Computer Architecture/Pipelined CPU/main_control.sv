// Brian Dallaire
// 12/3/2021
// EE 469
// Lab #4

// main_control takes the 11-bit input opcaode_Instr and the 1-bit inputs
// zero, negativeReg, overflReg and outputs the 1-bit outputs Reg2Loc,
// Branch, MemWrite, MemRead, RegWrite, UncondBr, setflags and the 2-bit
// outputs ALUSrc, MemtoReg and the 3-bit output ALUOp_bits. The purpose of this
// module is to act as the main control unit for the single cycle CPU. By outputting
// specific control signals the CPU can assume correct behavior after decoding an
// instruction.


`timescale 1ps/1ps

module main_control(opcode_Instr, zero_out, negative, overflow, negativeReg, overflReg, setflags_IDEX, Reg2Loc, ALUSrc, MemtoReg, MemRead, Branch, 
						  MemWrite, RegWrite, UncondBr, setflags, ALUOp_bits);

	input logic [10:0] opcode_Instr;
	input logic zero_out, negative, overflow, negativeReg, overflReg, setflags_IDEX;
	output logic Reg2Loc, Branch, MemWrite, MemRead, RegWrite, UncondBr, setflags;
	output logic [1:0] ALUSrc, MemtoReg;
	output logic [2:0] ALUOp_bits;
	
	logic branchLT, negativeflag, overflag;

	
		/* 
		
		
		if(instruction == B.LT && flag instruction is right before(setflags_IDEX == 1)) begin
			BranchLT = negative ^ overflow;
		end else begin
			BranchLT = negativeReg ^ overflReg;
		end
		
		
		*/	
		
	mux_2_1 nFlorReg (.select(setflags_IDEX), .load({negative, negativeReg}), .data(negativeflag));
	mux_2_1 oFlorReg (.select(setflags_IDEX), .load({overflow, overflReg}), .data(overflag));

	xor #50 xorBlt (branchLT, negativeflag, overflag); // xor gate 
	


	
	// using hex codes from textbook to identify opcodes from instruction set
	always_comb begin
		casex(opcode_Instr)
		// ADDI (488-489)
		11'b1001000100x : begin 	
									Reg2Loc = 1'b0;
									ALUSrc = 2'b10; // 2 is imm12 
									MemtoReg = 2'b00;
									Branch = 1'b0;
									MemWrite = 1'b0;
									MemRead = 1'b0;
									RegWrite = 1'b1;
									UncondBr = 1'bx; // is x
									setflags = 1'b0;
									ALUOp_bits = 3'b010; // ADD
								end 
		// ADDS (558)							
		11'b10101011000 : begin
									Reg2Loc = 1'b1;
									ALUSrc = 2'b00; 
									MemtoReg = 2'b00;
									Branch = 1'b0;
									MemWrite = 1'b0;
									MemRead = 1'b0;
									RegWrite = 1'b1;
									UncondBr = 1'bx; // is x
									setflags = 1'b1;
									ALUOp_bits = 3'b010; // ADD	
								end
		
		// Branch (0A0 - OBF)
		11'b000101xxxxx :  begin	
									Reg2Loc = 1'bx; // is x
									ALUSrc = 2'bxx; // is x 
									MemtoReg = 2'bxx; // is x
									Branch = 1'b1;
									MemWrite = 1'b0;
									MemRead = 1'b0;
									RegWrite = 1'b0;
									UncondBr = 1'b1; 
									setflags = 1'b0;
									ALUOp_bits = 3'bxxx; // is x
								 end
									
		// B.LT (2A0)							
		11'b01010100xxx : begin	
									Reg2Loc = 1'bx; // is x
									ALUSrc = 2'bxx; // is x
									MemtoReg = 2'bxx; // is x
									Branch = branchLT;  // is flag.negative ^ flag.overflow
									MemWrite = 1'b0;
									MemRead = 1'b0;
									RegWrite = 1'b0;
									UncondBr = 1'b0; 
									setflags = 1'b0;
									ALUOp_bits = 3'bxxx; // is x
								end
		
		// CBZ (5A0 - 5A7)
		11'b10110100xxx : begin	
									Reg2Loc = 1'b0;
									ALUSrc = 2'b00; 
									MemtoReg = 2'bxx; // is x
									Branch = zero_out; // is zero flag
									MemWrite = 1'b0;
									MemRead = 1'b0;
									RegWrite = 1'b0;
									UncondBr = 1'b0; 
									setflags = 1'b0;
									ALUOp_bits = 3'b000; // B-bypass
								end
		
		// LDUR (7C2)
		11'b11111000010 : begin
									Reg2Loc = 1'bx; // is x
									ALUSrc = 2'b01; 
									MemtoReg = 2'b01;
									Branch = 1'b0;
									MemWrite = 1'b0;
									MemRead = 1'b1;
									RegWrite = 1'b1;
									UncondBr = 1'bx; // is x
									setflags = 1'b0;
									ALUOp_bits = 3'b010; // ADD
								end
		
		// LSL (69B)
		11'b11010011011 : begin   
									Reg2Loc = 1'bx; // is x
									ALUSrc = 2'bxx; // is x
									MemtoReg = 2'b10;
									Branch = 1'b0;
									MemWrite = 1'b0;
									MemRead = 1'b0;
									RegWrite = 1'b1;
									UncondBr = 1'bx; // is x
									ALUOp_bits = 3'bxxx; // is x
								end
		
		// LSR (69A)
		11'b11010011010 :	begin	
									Reg2Loc = 1'bx; // is x
									ALUSrc = 2'bxx; // is x
									MemtoReg = 2'b10;
									Branch = 1'b0;
									MemWrite = 1'b0;
									MemRead = 1'b0;
									RegWrite = 1'b1;
									UncondBr = 1'bx; // is x
									ALUOp_bits = 3'bxxx; // is x
								end
		
		// MUL (4D8)
		11'b10011011000 :	begin	
									Reg2Loc = 1'b1; 
									ALUSrc = 2'bxx; // is x
									MemtoReg = 2'b11;
									Branch = 1'b0;
									MemWrite = 1'b0;
									MemRead = 1'b0;
									RegWrite = 1'b1;
									UncondBr = 1'bx; // is x
									ALUOp_bits = 3'bxxx; // is x
								end
		
		// STUR (7C0) 
		11'b11111000000 :	begin
									Reg2Loc = 1'b0;
									ALUSrc = 2'b01; 
									MemtoReg = 2'bxx; // is x
									Branch = 1'b0;
									MemWrite = 1'b1;
									MemRead = 1'b0;
									RegWrite = 1'b0;
									UncondBr = 1'bx; // is x
									setflags = 1'b0;
									ALUOp_bits = 3'b010; // ADD
								end
		
		// SUBS (758) 
		11'b11101011000 :	begin
									Reg2Loc = 1'b1;
									ALUSrc = 2'b00; 
									MemtoReg = 2'b00;
									Branch = 1'b0;
									MemWrite = 1'b0;
									MemRead = 1'b0;
									RegWrite = 1'b1;
									UncondBr = 1'bx; // is x
									setflags = 1'b1;
									ALUOp_bits = 3'b011; // SUB
								end
		
		default 			 :	 begin 
									Reg2Loc = 1'bx; // is x
									ALUSrc = 2'bxx; // is x 
									MemtoReg = 2'bxx; // is x
									Branch = 1'b0;
									MemWrite = 1'b0;
									MemRead = 1'b0;
									RegWrite = 1'b0;
									UncondBr = 1'bx; // is x
									setflags = 1'b0;
									ALUOp_bits = 3'bxxx; // is x
								 end
								
		endcase
	end
			
		
		
	
	
endmodule 

// main_control_testbench tests for the relevent cases in this module. In this testbench, I tested every single
// instruction and if they had output signals that were dependent on some of the input signals I tested all of
// those combinations.

module main_control_testbench();

	logic [10:0] opcode_Instr;
	logic zero_out, negative, overflow, negativeReg, overflReg;
	logic Reg2Loc, Branch, MemWrite, MemRead, RegWrite, UncondBr, setflags;
	logic [1:0] ALUSrc, MemtoReg;
	logic [2:0] ALUOp_bits;
	
	main_control dut (.opcode_Instr, .zero_out, .negative, .overflow, .negativeReg, .overflReg, .Reg2Loc, .ALUSrc, .MemtoReg, .MemRead, .Branch, .MemWrite, .RegWrite, .UncondBr, .setflags, .ALUOp_bits);
	
	initial begin 
		
		opcode_Instr = 11'h0; 	zero_out = 0; negativeReg = 0; overflReg = 0; #10000; // default
		
		opcode_Instr = 11'h488; zero_out = 0; negativeReg = 0; overflReg = 0; #10000;
		opcode_Instr = 11'h489; zero_out = 0; negativeReg = 0; overflReg = 0; #10000; // ADDI (488-489)
		
		opcode_Instr = 11'h558; zero_out = 0; negativeReg = 0; overflReg = 0; #10000; // ADDS (558)
		
		opcode_Instr = 11'h0A0; zero_out = 0; negativeReg = 0; overflReg = 0; #10000;
		opcode_Instr = 11'h0BF; zero_out = 0; negativeReg = 0; overflReg = 0; #10000;
		opcode_Instr = 11'h0B1; zero_out = 0; negativeReg = 0; overflReg = 0; #10000; // B (0A0 - 0BF)
		
		opcode_Instr = 11'h2A0; zero_out = 0; negativeReg = 0; overflReg = 0; #10000;
		opcode_Instr = 11'h2A0; zero_out = 0; negativeReg = 1; overflReg = 0; #10000;
		opcode_Instr = 11'h2A0; zero_out = 0; negativeReg = 0; overflReg = 1; #10000;
		opcode_Instr = 11'h2A0; zero_out = 0; negativeReg = 1; overflReg = 1; #10000; // B.LT (2A0) (flag.negative != flag.overflow)
		
		opcode_Instr = 11'h5A0; zero_out = 0; negativeReg = 0; overflReg = 0; #10000;
		opcode_Instr = 11'h5A7; zero_out = 1; negativeReg = 0; overflReg = 0; #10000;
		opcode_Instr = 11'h5A0; zero_out = 1; negativeReg = 0; overflReg = 0; #10000; // CBZ (5A0-5A7) (branch = zero flag)
		
		opcode_Instr = 11'h7C2; zero_out = 0; negativeReg = 0; overflReg = 0; #10000; // LDUR (7C2)
		
		opcode_Instr = 11'h69B; zero_out = 0; negativeReg = 0; overflReg = 0; #10000; // LSL
		
		opcode_Instr = 11'h69A; zero_out = 0; negativeReg = 0; overflReg = 0; #10000; // LSR
		
		opcode_Instr = 11'h4D8; zero_out = 0; negativeReg = 0; overflReg = 0; #10000; // MUL
		
		opcode_Instr = 11'h7C0; zero_out = 0; negativeReg = 0; overflReg = 0; #10000; // sTUR
		
		opcode_Instr = 11'h758; zero_out = 0; negativeReg = 0; overflReg = 0; #10000; // SUBS

		
		$stop;
	end
endmodule 