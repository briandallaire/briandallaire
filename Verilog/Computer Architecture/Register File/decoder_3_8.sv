`timescale 1ps/1ps

module decoder_3_8 (enable, selectbits, enable_reg);

	input logic enable;
	input logic [2:0] selectbits;
	output logic [7:0] enable_reg;
	
	logic notS2, notS1, notS0;
	
	not #50 notGate1 (notS0, selectbits[0]);
	not #50 notGate2 (notS1, selectbits[1]);
	not #50 notGate3 (notS2, selectbits[2]);
	
	and #50 andGate1 (enable_reg[0], notS2, notS1, notS0, enable);
	and #50 andGate2 (enable_reg[1], notS2, notS1, selectbits[0], enable);
	and #50 andGate3 (enable_reg[2], notS2, selectbits[1], notS0, enable);
	and #50 andGate4 (enable_reg[3], notS2, selectbits[1], selectbits[0], enable);
	and #50 andGate5 (enable_reg[4], selectbits[2], notS1, notS0, enable);
	and #50 andGate6 (enable_reg[5], selectbits[2], notS1, selectbits[0], enable);
	and #50 andGate7 (enable_reg[6], selectbits[2], selectbits[1], notS0, enable);
	and #50 andGate8 (enable_reg[7], selectbits[2], selectbits[1], selectbits[0], enable);
	
	
endmodule


module decoder_3_8_testbench();

	logic enable;
	logic [2:0] selectbits;
	logic [7:0] enable_reg;
	
	decoder_3_8 dut (.enable, .selectbits, .enable_reg);
	
	initial begin
	
	enable = 0; selectbits = 3'b000; #50;
											   #50;
	enable = 1; selectbits = 3'b000; #50;
											   #50;
	enable = 0; selectbits = 3'b001; #50;
											   #50;
	enable = 1; selectbits = 3'b001; #50;
											   #50;
	enable = 0; selectbits = 3'b010; #50;
											   #50;
	enable = 1; selectbits = 3'b010; #50;
											   #50;
	enable = 0; selectbits = 3'b011; #50;
											   #50;
	enable = 1; selectbits = 3'b011; #50;
											   #50;
	enable = 0; selectbits = 3'b100; #50;
											   #50;
	enable = 1; selectbits = 3'b100; #50;
											   #50;
	enable = 0; selectbits = 3'b101; #50;
											   #50;
	enable = 1; selectbits = 3'b101; #50;
											   #50;
	enable = 0; selectbits = 3'b110; #50;
											   #50;
	enable = 1; selectbits = 3'b110; #50;
											   #50;
	enable = 0; selectbits = 3'b111; #50;
											   #50;
	enable = 1; selectbits = 3'b111; #50;
											   #50;
	
	$stop;
	
	end 
	
endmodule 