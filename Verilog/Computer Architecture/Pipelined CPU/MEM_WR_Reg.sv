// Brian Dallaire
// 12/3/2021
// EE 469
// Lab #4

// MEM_WR_Reg takes the 1-bit inputs clk, reset, and RegWrite_EXMEM and the 5-bit input Rd_MEM
// and the 64-bit input writeData and outputs the 1-bit output RegWrite_MEMWR and the 5-bit 
// output Rd_WB and the 64-bit output Dw. The main purpose of this module is to represent the
// register that separates the MEM stage and WR stage in the pipelined processor.

`timescale 1ps/1ps

module MEM_WR_Reg(clk, reset, RegWrite_EXMEM, RegWrite_MEMWR, Rd_MEM, Rd_WB, writeData, Dw);
	
	input logic clk, reset;
	input logic RegWrite_EXMEM;
	input logic [4:0] Rd_MEM;
	input logic [63:0] writeData;
	
	output logic RegWrite_MEMWR;
	output logic [4:0] Rd_WB;
	output logic [63:0] Dw;
	
	D_FF RWR (.q(RegWrite_MEMWR), .d(RegWrite_EXMEM), .reset, .clk);

	varSize_D_FF #(.WIDTH(5)) RD  (.clk, .reset, .d_in(Rd_MEM), .q_out(Rd_WB));
	varSize_D_FF #(.WIDTH(64)) WRD (.clk, .reset, .d_in(writeData), .q_out(Dw));

endmodule 

// MEM_WR_Reg_testbench tests whether the registers all work properly for all inputs and outputs.

module MEM_WR_Reg_testbench();

	logic clk, reset;
	logic RegWrite_EXMEM;
	logic [4:0] Rd_MEM;
	logic [63:0] writeData;
	
	logic RegWrite_MEMWR;
	logic [4:0] Rd_WB;
	logic [63:0] Dw;

	MEM_WR_Reg dut (.clk, .reset, .RegWrite_EXMEM, .RegWrite_MEMWR, .Rd_MEM, .Rd_WB, .writeData, .Dw);
	
	parameter CLOCK_PERIOD = 100;
	
	initial begin 
		clk <= 0;
		forever #(CLOCK_PERIOD/2) clk <= ~clk;
	end
	
	initial begin 
		reset <= 1; @(posedge clk);
		reset <= 0; RegWrite_EXMEM <= 0; Rd_MEM <= 5'b00000; writeData <= 64'd0; repeat(2) @(posedge clk);
						RegWrite_EXMEM <= 1; Rd_MEM <= 5'b00111; writeData <= 64'd538; repeat(2) @(posedge clk);
						RegWrite_EXMEM <= 0; Rd_MEM <= 5'b00000; writeData <= 64'd0; repeat(2) @(posedge clk);
	
		$stop;
	end

endmodule 