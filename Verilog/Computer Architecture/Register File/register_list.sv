
`timescale 1ps/1ps

module register_list (clk, reset, WriteEnable, WriteData, read_list);

	input logic clk, reset;
	input logic [31:0] WriteEnable;
	input logic [63:0] WriteData;
	output logic [31:0][63:0] read_list;
	
	genvar i;
	
	generate
	
		for(i = 0; i < 31; i++) begin : all_registers
			register_64 register_i (.clk, .reset, .write_en(WriteEnable[i]), .DataIn(WriteData), .DataOut(read_list[i]));
		end
			
		assign read_list[31] = 0;
		
	endgenerate

endmodule 

