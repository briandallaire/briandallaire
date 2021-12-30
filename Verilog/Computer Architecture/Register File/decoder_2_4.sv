`timescale 1ps/1ps

module decoder_2_4 (RegWrite, select, enabler);

	input logic RegWrite;	    // acts as overall enable of 5:32 decoder
	input logic [1:0] select;   // i4 = select[1], i3 = select[0]
	output logic [3:0] enabler; // sends enable bits to other 3:8 decoders
	
	logic notS0, notS1;
	
	not #50 notGate1 (notS0, select[0]);
	not #50 notGate2 (notS1, select[1]);
	
	and #50 andGate1 (enabler[0], notS1, notS0, RegWrite);
	and #50 andGate2 (enabler[1], notS1, select[0], RegWrite);
	and #50 andGate3 (enabler[2], select[1], notS0, RegWrite);
	and #50 andGate4 (enabler[3], select[1], select[0], RegWrite);
	
endmodule 

module decoder_2_4_testbench();

	logic RegWrite;
	logic [1:0] select;
	logic [3:0] enabler;
	
	decoder_2_4 dut (.RegWrite, .select, .enabler);
	
	initial begin
	
	RegWrite = 0; select = 2'b00; #50;
											#50; // needs buffer maybe?
	RegWrite = 1; select = 2'b00; #50;
											#50;
	RegWrite = 0; select = 2'b01; #50;
											#50;
	RegWrite = 1; select = 2'b01; #50;
											#50;
	RegWrite = 0; select = 2'b10; #50;
											#50;
	RegWrite = 1; select = 2'b10; #50;
											#50;
	RegWrite = 0; select = 2'b11; #50;
											#50;
	RegWrite = 1; select = 2'b11; #50;
											#50;
	
	$stop;
	
	end 
	
endmodule 