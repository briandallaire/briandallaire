module DE1_SoC (HEX0, HEX1, HEX2, HEX3, HEX4, HEX5, KEY, SW);

	output logic [6:0] HEX0, HEX1, HEX2, HEX3, HEX4, HEX5;
	input logic [3:0] KEY;
	input logic [9:0] SW;
	
	
	assign HEX3 = 7'b1111111;
	assign HEX1 = 7'b1111111;
//	
//	logic [3:0] dataOut; 
//
//	// add series_dffs for metastability
//	RAM32_4 				ram 	  (.clk(~KEY[0]), .write(SW[9]), .dataIn(SW[3:0]), .address(SW[8:4]), .dataOut);
//	displayOrganizer displays (.dataIn(SW[3:0]), .address(SW[8:4]), .dataOut, .hexArray({HEX5, HEX4, HEX2, HEX0}));
//	
	
endmodule 


module DE1_SoC_testbench();

	logic [6:0] HEX0, HEX1, HEX2, HEX3, HEX4, HEX5;
	logic [3:0] KEY;
	logic [9:0] SW;
	
	DE1_SoC dut (.HEX0, .HEX1, .HEX2, .HEX3, .HEX4, .HEX5, .KEY, .SW);
	
	
endmodule 