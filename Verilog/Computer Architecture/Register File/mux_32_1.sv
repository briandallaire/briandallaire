`timescale 1ps/1ps

module mux_32_1 (select_read, input_read, output_read);
	
	input logic  [4:0]  select_read;
	input logic  [31:0] input_read;
	output logic 		  output_read;
	
	logic [7:0] frst_lvl_output;
	logic [1:0] scnd_lvl_output;
	
	mux_4_1 mux1 (.inputSelect(select_read[1:0]), .loadbits(input_read[3:0]), .outData(frst_lvl_output[0]));
	mux_4_1 mux2 (.inputSelect(select_read[1:0]), .loadbits(input_read[7:4]), .outData(frst_lvl_output[1]));
	mux_4_1 mux3 (.inputSelect(select_read[1:0]), .loadbits(input_read[11:8]), .outData(frst_lvl_output[2]));
	mux_4_1 mux4 (.inputSelect(select_read[1:0]), .loadbits(input_read[15:12]), .outData(frst_lvl_output[3]));
	mux_4_1 mux5 (.inputSelect(select_read[1:0]), .loadbits(input_read[19:16]), .outData(frst_lvl_output[4]));
	mux_4_1 mux6 (.inputSelect(select_read[1:0]), .loadbits(input_read[23:20]), .outData(frst_lvl_output[5]));
	mux_4_1 mux7 (.inputSelect(select_read[1:0]), .loadbits(input_read[27:24]), .outData(frst_lvl_output[6]));
	mux_4_1 mux8 (.inputSelect(select_read[1:0]), .loadbits(input_read[31:28]), .outData(frst_lvl_output[7]));
	
	mux_4_1 mux9  (.inputSelect(select_read[3:2]), .loadbits(frst_lvl_output[3:0]), .outData(scnd_lvl_output[0]));
	mux_4_1 mux10 (.inputSelect(select_read[3:2]), .loadbits(frst_lvl_output[7:4]), .outData(scnd_lvl_output[1]));

	mux_2_1 mux11 (.select(select_read[4]), .load(scnd_lvl_output), .data(output_read)); 

	
	
	/*
	genvar i;
	
	generate
		for(i = 0; i < 32; i += 4) begin : bigmux
			mux_4_1 mux_i (.inputSelect(select_read[1:0]), .loadbits(input_read[(i+3):i], .outData(frst_lvl_output[(i/4)]));
	*/		

	
endmodule 