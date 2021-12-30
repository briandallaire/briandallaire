// Brian Dallaire
// 12/3/2021
// EE 469
// Lab #4

// register_list takes the 1-bit inputs clk and reset and the 32-bit input WriteEnable and the 64-bit
// input WriteData and outputs 32, 64-bit outputs read_list. The purpose of this module is to represent
// or group all 32, 64-bit wide registers so we can implement it into the 64x32:1 muxes later.  

`timescale 1ps/1ps

module register_list (clk, reset, WriteEnable, WriteData, read_list);

	input logic clk, reset;
	input logic [31:0] WriteEnable;
	input logic [63:0] WriteData;
	output logic [31:0][63:0] read_list;
	
	
	// this generate statement takes the 32 enable bits from the 5:32 decoder and 64-bit data and uses register_64
	// to group all 32 registers into the output read_list.
	genvar i;
	generate
	
		for(i = 0; i < 31; i++) begin : all_registers
			register_64 register_i (.clk, .reset, .write_en(WriteEnable[i]), .DataIn(WriteData), .DataOut(read_list[i]));
		end
		
		// the for loop does not account for read_list[31] since it is hard wired to be the zero register
		assign read_list[31] = 0;
		
	endgenerate

endmodule 

// register_list_testbench tests for relevant behaviors. In this testbench, I tested a couple of values and
// saw if the write enable properly relayed the write data into the read list.

module register_list_testbench();

	logic 		 		 clk, reset;
	logic [31:0] 		 WriteEnable;
	logic [63:0] 		 WriteData;
	logic [31:0][63:0] read_list;
	
	register_list dut (.clk, .reset, .WriteEnable, .WriteData, .read_list);

	parameter CLOCK_PERIOD = 1000;
	
	initial begin 
		clk <= 0;
		forever #(CLOCK_PERIOD/2) clk <= ~clk;
	end
	
	initial begin 
	
		reset <= 1; WriteEnable <= 32'h0; WriteData <= 64'd0; 				  @(posedge clk);
		reset <= 0; WriteEnable <= 32'hFFFFFFFF; WriteData <= 64'hF3473245; @(posedge clk);
		reset <= 0; WriteEnable <= 32'h2487325F; WriteData <= 64'h21391832; @(posedge clk);
		reset <= 0; WriteEnable <= 32'h34902347; WriteData <= 64'h32483294; @(posedge clk);
			
		$stop;
	end
endmodule 