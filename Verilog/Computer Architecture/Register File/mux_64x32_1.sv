// do 64 iterations of a 32x1 mux
// (dataIn[i] is one bit wide, outputs need to be 64 bits wide)

`timescale 1ps/1ps
module mux_64x32_1 (ReadRegister, inputData, ReadData);
	
	input logic  [4:0] ReadRegister;
	input logic  [63:0][31:0] inputData;
	output logic [63:0] ReadData;
	
	genvar i;
	
	generate
		for(i = 0; i < 64; i++) begin : largemux
			mux_32_1 mux_32_1_i (.select_read(ReadRegister), .input_read(inputData[i]), .output_read(ReadData[i]));
		end
	endgenerate

endmodule 