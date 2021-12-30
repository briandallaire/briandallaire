// Brian Dallaire
// 12/3/2021
// EE 469
// Lab #4

// forwardingUnit takes the 32-bit input instr and 5-bit inputs addrA, addrB, Rd_EX, Rd_MEM and
// the 2-bit input ALUSrc and the 1-bit inputs RegWrite_IDEX, RegWrite_EXMEM and outputs the 2-bit
// outputs fwrdCntrl_A and fwrdCntrl_B. The purpose of this module is to act as the forwarding unit
// for the ARM pipelined CPU to avoid hazards. It sends control signals to the forwarding muxes
// so they send through values that avoid hazards.

`timescale 1ps/1ps

module forwardingUnit(addrA, addrB, instr, Rd_EX, Rd_MEM, RegWrite_IDEX, RegWrite_EXMEM, fwrdCntrl_A, fwrdCntrl_B, ALUSrc);

	input logic [31:0] instr;
	input logic [4:0] addrA, addrB, Rd_EX, Rd_MEM;
	input logic [1:0] ALUSrc;
	input logic RegWrite_IDEX, RegWrite_EXMEM;
	output logic [1:0] fwrdCntrl_A, fwrdCntrl_B; 

	
	always_comb begin 
		
		// control for forwarding A value
		if ((RegWrite_IDEX == 1'b1) && (Rd_EX != 5'd31) && (Rd_EX == addrA)) begin
			fwrdCntrl_A = 2'b10;
		end else if((RegWrite_EXMEM == 1'b1) && (Rd_MEM != 5'd31) && (Rd_MEM == addrA)) begin
			fwrdCntrl_A = 2'b01;
		end else begin
			fwrdCntrl_A = 2'b00;
		end
		
		// control for fowarding B value
		if ((RegWrite_IDEX == 1'b1) && (Rd_EX != 5'd31) && (Rd_EX == addrB) && (instr[31:22] != 10'b1001000100)) begin
			fwrdCntrl_B = 2'b10;
		end else if ((RegWrite_EXMEM == 1'b1) && (Rd_MEM != 5'd31) && (Rd_MEM == addrB) && (instr[31:22] != 10'b1001000100)) begin
			fwrdCntrl_B = 2'b01;
		end else if ((ALUSrc == 2'b01) && (Rd_EX != 5'd31) && (Rd_EX == addrB)) begin
			fwrdCntrl_B = 2'b10;
		end else if ((ALUSrc == 2'b01) && (Rd_MEM != 5'd31) && (Rd_MEM == addrB)) begin
			fwrdCntrl_B = 2'b01; 
		end else if ((instr[31:24] == 8'b10110100) && (Rd_EX != 5'd31) && (Rd_EX == addrB)) begin
			fwrdCntrl_B = 2'b10;
		end else if ((instr[31:24] == 8'b10110100) && (Rd_MEM != 5'd31) && (Rd_MEM == addrB)) begin
			fwrdCntrl_B = 2'b01;	
		end else begin
			fwrdCntrl_B = 2'b00;
		end
		
	end
	
endmodule 

module forwardingUnit_testbench();

	parameter delay = 100000;

	logic [31:0] instr;
	logic [4:0] addrA, addrB, Rd_EX, Rd_MEM;
	logic [1:0] ALUSrc;
	logic RegWrite_IDEX, RegWrite_EXMEM;
	
	logic [1:0] fwrdCntrl_A, fwrdCntrl_B; 
	
	forwardingUnit dut (.addrA, .addrB, .instr, .Rd_EX, .Rd_MEM, .RegWrite_IDEX, .RegWrite_EXMEM, .fwrdCntrl_A, .fwrdCntrl_B, 
							  .ALUSrc);
	
	// Force %t's to print in a nice format.
	initial $timeformat(-9, 2, " ns", 10);

	int i, j, k, l, m, n, p, q;
	
	initial begin
	
		
		for(i = 0; i < 32; i++) begin // set addrA
						addrA = i[4:0];
			for(j = 0; j < 32; j++) begin	// set addrB
						addrB = j[4:0];
				for(k = 0; k < 32; k++) begin // set Rd_EX value
						Rd_EX = k[4:0];
					for(l = 0; l < 32; l++) begin // set Rd_MEM value
						Rd_MEM = l[4:0];
						for(m = 0; m < 4; m++) begin
							ALUSrc = m[1:0];
							for(n = 0; n < 2; n++) begin
								RegWrite_IDEX = n[0];
								for(p = 0; p < 2; p++) begin
									RegWrite_EXMEM = p[0];
									for(q = 0; q < 2; q++) begin
										if(q == 0) begin
											instr = {10'b1001000100, 22'b0};
										end else begin
											instr = '0;
										end
										#(delay);
										
										// control for forwarding A value
										if ((RegWrite_IDEX == 1'b1) && (Rd_EX != 5'd31) && (Rd_EX == addrA)) begin
											assert(fwrdCntrl_A == 2'b10);
										end else if((RegWrite_EXMEM == 1'b1) && (Rd_MEM != 5'd31) && (Rd_MEM == addrA)) begin
											assert(fwrdCntrl_A == 2'b01);
										end else begin
											assert(fwrdCntrl_A == 2'b00);
										end
										
										// control for fowarding B value
										if ((RegWrite_IDEX == 1'b1) && (Rd_EX != 5'd31) && (Rd_EX == addrB) && (instr[31:22] != 10'b1001000100)) begin
											assert(fwrdCntrl_B == 2'b10);
										end else if ((RegWrite_EXMEM == 1'b1) && (Rd_MEM != 5'd31) && (Rd_MEM == addrB) && (instr[31:22] != 10'b1001000100)) begin
											assert(fwrdCntrl_B == 2'b01);
										end else if ((ALUSrc == 2'b01) && (Rd_EX != 5'd31) && (Rd_EX == addrB)) begin
											assert(fwrdCntrl_B == 2'b10);
										end else if ((ALUSrc == 2'b01) && (Rd_MEM != 5'd31) && (Rd_MEM == addrB)) begin
											assert(fwrdCntrl_B == 2'b01); 
										end else if ((instr[31:24] == 8'b10110100) && (Rd_EX != 5'd31) && (Rd_EX == addrB)) begin
											assert(fwrdCntrl_B == 2'b10);
										end else if ((instr[31:24] == 8'b10110100) && (Rd_MEM != 5'd31) && (Rd_MEM == addrB)) begin
											assert(fwrdCntrl_B == 2'b01);	
										end else begin
											assert(fwrdCntrl_B == 2'b00);
										end
										
									end	
								end
							end
						end
					end
				end
			end
		end
		
		$stop;
	end







endmodule 