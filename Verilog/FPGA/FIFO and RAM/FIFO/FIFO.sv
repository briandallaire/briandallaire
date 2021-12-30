// Brian Dallaire
// 04/23/2021
// EE 371
// Lab #2, Task 3

// FIFO takes the 1-bit inputs clk, reset, read, and write and the variable-bit inputBus input and ouputs/
// the 1-bit outputs empty and full and the variable-bit output outputBus. inputBus and outputBus are variable
// length determined by the global parameter width. The purpose of this module is to connect the 16x8 dual-port
// RAM module and the FIFO control module to represent the overall FIFO. 

module FIFO #(parameter depth = 4,parameter width = 8)
				 (clk, reset, read, write, inputBus, empty, full, outputBus);

   input logic clk, reset;
	input logic read, write;
	input logic [width-1:0] inputBus;
	output logic empty, full;
	output logic [width-1:0] outputBus;

	/* 	Define_Variables_Here		*/
	logic wr_en;
	logic [depth-1:0] writeAddr, readAddr;
	
	// ram16x8 is a verilog file that uses 1-bit input clk, 8-bit input inputBus, 4-bit inputs rdaddress and wraddress,
	// and 1-bit input wren to output the 8-bit output outputBus. The purpose of this module is that it is the 16x8 dual-port
	// RAM that the IP catalog generated and is the core of the FIFO
	ram16x8 ram (.clock(clk), .data(inputBus), .rdaddress(readAddr), .wraddress(writeAddr),
					 .wren(wr_en), .q(outputBus));
	
	// FIFO_control uses the 1-bit inputs clk, reset, read and write and outputs the 1-bit outputs wr_en, empty, and full and
   // outputs the variable-bit outputs readAddr and writeAddr. In this lab, these outputs are 4 bits since global parameter
   // depth is set to 4. The purpose of this module is to control the overall behavior of the FIFO and keep things organized
   // The FIFO_Control makes sure the FIFO behaves a certain way when it is full or empty, and allows for data to be written
   // into or read from the RAM. 	
	FIFO_Control #(depth) FC (.clk, .reset, .read, .write, .wr_en, .empty, .full, .readAddr, .writeAddr);
	
endmodule 

// FIFO_testbench tests both expected and unexpected situations. In this simulation, I tested if the FIFO can reach full
// or empty properly, and if it outputs the proper 1-bit empty and full outputs or the 4-bit outputBus value.

`timescale 1 ps / 1 ps
module FIFO_testbench();
	
	parameter depth = 4, width = 8;
	
	logic clk, reset;
	logic read, write;
	logic [width-1:0] inputBus;
	logic resetState;
	logic empty, full;
	logic [width-1:0] outputBus;
	
	FIFO #(depth, width) dut (.*);
	
	parameter CLK_Period = 100;
	
	initial begin
		clk <= 1'b0;
		forever #(CLK_Period/2) clk <= ~clk;
	end
	
		initial begin
															@(posedge clk);
		reset <= 1; 									@(posedge clk); 
		reset <= 0; 									@(posedge clk);
															@(posedge clk);
		inputBus <= 8'b10001000; read <= 0; write <= 0; @(posedge clk);
															@(posedge clk);
		write <= 1;										@(posedge clk);
		write <= 0;										@(posedge clk);
															@(posedge clk);
		repeat (15) begin
			write <= 1;									@(posedge clk);
			write <= 0;									@(posedge clk);
		end
															@(posedge clk);
		read <= 1;										@(posedge clk);	
		read <= 0;										@(posedge clk);
															@(posedge clk);
		repeat (15) begin
			read <= 1;									@(posedge clk);
			read <= 0;									@(posedge clk);
		end
															@(posedge clk);
															@(posedge clk);
															@(posedge clk);
		$stop;
	end

endmodule 