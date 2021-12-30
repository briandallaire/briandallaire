// Brian Dallaire
// 11/12/2021
// EE 469
// Lab #3

// register_64 takes the 1-bit inputs clk, reset, write_en and the 64-bit input
// DataIn and outputs the 64-bit output DataOut. The purpose of this module is to
// represent a 64 D flip flop wide register that represents an individual
// register within the 32 by 64 ARM Register File

`timescale 1ps/1ps

module register_64 (clk, reset, write_en, DataIn, DataOut);
	
	input logic			  clk, reset, write_en;
	input logic [63:0]  DataIn;
	output logic [63:0] DataOut;
	
	// used to connect mux to the flip flop
	logic [63:0]mux_data;
	
	// this generate statement is used to create a 64-bit wide register that only writes
	// when the enable bit is true. 
	genvar i;
	generate 
		for(i = 0; i < 64; i++) begin : large_register
			
			// 2:1 mux takes old value from flip flop and new value from DataIn and outputs one
			// into the flip flop depending on write_en
			mux_2_1 mux2_1 (.select(write_en), .load({DataIn[i], DataOut[i]}), .data(mux_data[i]));
			D_FF nextregister (.q(DataOut[i]), .d(mux_data[i]), .reset, .clk);
			
		end
	endgenerate
endmodule 

// register_64_testbench tests for relvant behaviors. This testbench simply tests a couple different
// values and sees the effects of the write enable signal.

module register_64_testbench();

	logic			  clk, reset, write_en;
	logic [63:0]  DataIn;
	logic [63:0] DataOut;

	register_64 dut (.clk, .reset, .write_en, .DataIn, .DataOut);
	
	parameter CLOCK_PERIOD = 1000;
	
	initial begin 
		clk <= 0;
		forever #(CLOCK_PERIOD/2) clk <= ~clk;
	end

	initial begin 
	
	reset <= 1; DataIn <= 64'd1348; write_en <= 0;            @(posedge clk);
	reset <= 0; DataIn <= 64'd1348; write_en <= 0;  repeat(2) @(posedge clk);
	reset <= 0; DataIn <= 64'd1348; write_en <= 1;  repeat(2) @(posedge clk);
	reset <= 0; DataIn <= 64'd45948; write_en <= 1; repeat(2) @(posedge clk);
	reset <= 0; DataIn <= 64'd45948; write_en <= 0; repeat(4	) @(posedge clk);
	
	$stop;
	end
endmodule 