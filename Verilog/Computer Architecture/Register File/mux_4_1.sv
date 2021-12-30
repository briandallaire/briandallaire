`timescale 1ps/1ps

module mux_4_1 (inputSelect, loadbits, outData);

	input logic [1:0] inputSelect;
	input logic [3:0] loadbits;
	output logic outData;
	
	logic notS1, notS0, and1, and2, and3, and4;
	
	not #50 notGate1 (notS1, inputSelect[1]);
	not #50 notGate2 (notS0, inputSelect[0]);
	
	and #50 andGate1 (and1, notS1, notS0, loadbits[0]);
	and #50 andGate2 (and2, notS1, inputSelect[0], loadbits[1]);
	and #50 andGate3 (and3, inputSelect[1], notS0, loadbits[2]);
	and #50 andGate4 (and4, inputSelect[1], inputSelect[0], loadbits[3]);
	
	or #50 orGate1   (outData, and1, and2, and3, and4);
	
endmodule 

module mux_4_1_testbench();

	logic [1:0] inputSelect;
	logic [3:0] loadbits;
	logic outData;
	
	mux_4_1 dut (.inputSelect, .loadbits, .outData);
	
	initial begin
	
	inputSelect = 2'b00; loadbits = 4'b0000; #150;
														  #50;
	inputSelect = 2'b01; loadbits = 4'b0000; #150;
														  #50;
	inputSelect = 2'b10; loadbits = 4'b0000; #150;
														  #50;
	inputSelect = 2'b11; loadbits = 4'b0000; #150;
														  #50;
	inputSelect = 2'b00; loadbits = 4'b0101; #150;
														  #50;	
	inputSelect = 2'b10; loadbits = 4'b0101; #150;
														  #50;
	inputSelect = 2'b11; loadbits = 4'b0101; #150;
														  #50;	
	inputSelect = 2'b01; loadbits = 4'b0101; #150;
														  #50;
	
	$stop;
	end
endmodule 