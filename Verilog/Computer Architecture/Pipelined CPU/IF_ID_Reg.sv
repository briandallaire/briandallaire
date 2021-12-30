`timescale 1ps/1ps

// Brian Dallaire
// 12/3/2021
// EE 469
// Lab #4

// IF_ID_Reg takes in the 1-bit inputs clk and reset adn the 32-bit input instr_in
// and the 64-bit input PC_in and outputs the 32-bit output instr_out and the 64-bit
// output PC_out. The purpose of this module is to act as the register between the 
// IF and ID stage in the pipelined CPU.

`timescale 1ps/1ps

module IF_ID_Reg (clk, reset, PC_in, PC_out, instr_in, instr_out);

	input logic  clk, reset;
	input logic  [31:0] instr_in;
	input logic  [63:0] PC_in;
	output logic [31:0] instr_out;
	output logic [63:0] PC_out;
	
	
	varSize_D_FF #(.WIDTH(32)) instrDFF (.clk, .reset, .d_in(instr_in), .q_out(instr_out));
	
	varSize_D_FF #(.WIDTH(64)) PC_DFF (.clk, .reset, .d_in(PC_in), .q_out(PC_out));

endmodule 

// IF_ID_Reg_testbench tests whether the registers all work properly for all inputs and outputs.

module IF_ID_Reg_testbench();

	logic  clk, reset;
	logic  [31:0] instr_in;
	logic  [63:0] PC_in;
	logic [31:0] instr_out;
	logic [63:0] PC_out;
	
	IF_ID_Reg dut (.clk, .reset, .PC_in, .PC_out, .instr_in, .instr_out);
	
	parameter CLOCK_PERIOD = 100;
	
	initial begin 
		clk <= 0;
		forever #(CLOCK_PERIOD/2) clk <= ~clk;
	end
	
	initial begin 
	
		reset <= 1; @(posedge clk);
		reset <= 0; PC_in <= 64'd0; instr_in <= 32'd0; repeat(2) @(posedge clk);
						PC_in <= 64'd420; instr_in <= 32'd420; repeat(2) @(posedge clk);
						PC_in <= 64'd0; instr_in <= 32'd0; repeat(2) @(posedge clk);
	
		$stop;
		
	end
	

endmodule 