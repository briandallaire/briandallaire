`timescale 1ps/1ps

module logicalShift_L (dataIn, shift, shiftedData);
	
	input logic [63:0] dataIn;
	input logic [5:0] shift;
	output logic [63:0] shiftedData;
	
	
	logic [5:0][63:0] muxout;
	
	genvar i, j;
	
	generate 
	
		for(i = 0; i < 6; i++) begin : shift_amnt
			for(j = 0; j < 64; j++) begin : mux_number
				
				if(i == 0) begin 
					if(j != 0) begin
						mux_2_1 mux_0 (.select(shift[0]), .load({dataIn[j-1], dataIn[j]}), .data(muxout[0][j]));
					end else begin
						mux_2_1 mux_0i (.select(shift[0]), .load({1'b0, dataIn[j]}), .data(muxout[0][j]));
					end
				end else begin
				
					if((j - (2**i)) >= 0) begin
						mux_2_1 mux_j (.select(shift[i]), .load({muxout[i-1][(j - (2**i))], muxout[i-1][j]}), .data(muxout[i][j])); 
					end else begin
						mux_2_1 mux_0j (.select(shift[i]), .load({1'b0, muxout[i-1][j]}), .data(muxout[i][j]));
					end
				end
			end
		end
		
		assign shiftedData = muxout[5];
		
	endgenerate
		

endmodule 

module logicalShift_L_testbench();

	logic [63:0] dataIn;
	logic [5:0] shift;
	logic [63:0] shiftedData;
	
	logicalShift_L dut (.dataIn, .shift, .shiftedData);
	
	initial begin 
	
	dataIn = 64'd455; shift <= 6'd6; #10000;
	
	$stop;
	end
endmodule 