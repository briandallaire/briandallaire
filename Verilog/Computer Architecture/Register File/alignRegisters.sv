`timescale 1ps/1ps

module alignRegisters (read_list, connctMux);

	input logic  [31:0][63:0] read_list;
	output logic [63:0][31:0] connctMux;
	
	genvar j, k;
	
	generate
		for(j = 0; j < 64; j++) begin : regBit
			for(k = 0; k < 32; k++) begin : registerNum
				assign connctMux[j][k] = read_list[k][j];
			end
		end
	endgenerate 
	
endmodule 