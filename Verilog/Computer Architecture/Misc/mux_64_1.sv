`timescale 1ps/1ps

module mux_64_1 (selectbits, load64, outmux64);

	input logic [5:0] selectbits;
	input logic [63:0] load64;
	output logic outmux64;
	
	logic muxout1, muxout2;

	mux_32_1 mux1 (.select_read(selectbits[4:0]), .input_read(load64[31:0]), .output_read(muxout1));
	mux_32_1 mux2 (.select_read(selectbits[4:0]), .input_read(load64[63:32]), .output_read(muxout2));
	mux_2_1  mux3 (.select(selectbits[5]), .load({muxout2, muxout1}), .data(outmux64)); 

	
endmodule 

module mux_64_1_testbench();

	logic [5:0] selectbits;
	logic [63:0] load64;
	logic outmux64;
	
	mux_64_1 dut (.selectbits, .load64, .outmux64);
	
	int i;
	
	initial begin 
	
	load64 <= 64'd69420;
	for(i = 0; i < 64; i++) begin
		selectbits[5] <= i[5];
		selectbits[4] <= i[4];
		selectbits[3] <= i[3];
		selectbits[2] <= i[2];
		selectbits[1] <= i[1];
		selectbits[0] <= i[0]; #3000;
	end

	
	load64 <= 64'd23485;
	for(i = 0; i < 64; i++) begin
		selectbits = i; #3000;
	end
	
	$stop;
	end
endmodule 
