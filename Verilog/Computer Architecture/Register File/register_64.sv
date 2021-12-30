// 64 D flip flop wide register that represents an individual
// register within the 32 by 64 ARM Register File

`timescale 1ps/1ps

module register_64 (clk, reset, write_en, DataIn, DataOut);
	
	input logic			  clk, reset, write_en;
	input logic [63:0]  DataIn;
	output logic [63:0] DataOut;
	
	logic [63:0]mux_data;
	
	genvar i;
	
	generate 
		for(i = 0; i < 64; i++) begin : large_register
			
			mux_2_1 mux2_1 (.select(write_en), .load({DataIn[i], DataOut[i]}), .data(mux_data[i]));
			D_FF nextregister (.q(DataOut[i]), .d(mux_data[i]), .reset, .clk);
			
		end
	endgenerate
endmodule 