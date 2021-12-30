// Brian Dallaire
// 12/3/2021
// EE 469
// Lab #4

// adder_64 takes the 64-bit inputs inA and inB and outputs the 64-bit output addSum.
// The purpose of this module is to add the two inputs and output their sum. To do this,
// it utilizes the fullAdder module and instantiates it 64 times to replicate a 64-bit
// adder. Thus, two 64-bit inputs are added together and outputted as a 64-bit output.
 
`timescale 1ps/1ps
 
module adder_64 (inA, inB, addSum);

	input logic [63:0] inA, inB;
	output logic [63:0] addSum;

	logic [63:0] carrys;
	
	
	genvar i;
	
	generate 
		for(i = 0; i < 64; i++) begin : adder64Bit
			if(i == 0) begin
				fullAdder firstAdd (.A(inA[0]), .B(inB[0]), .Cin(1'b0), .S(addSum[0]), .Cout(carrys[0]));
			end else begin
				fullAdder Addbits  (.A(inA[i]), .B(inB[i]), .Cin(carrys[i - 1]), .S(addSum[i]), .Cout(carrys[i]));
			end
		end
	endgenerate

endmodule 

// fullAdder_testbench tests both the expected and unexpected cases in this module. For this testbench
// I tested multiple values including those that will make the sum out of bounds when added together. 

module adder_64_testbench();

	logic [63:0] inA, inB;
	logic [63:0] addSum;
	
	adder_64 dut (.inA, .inB, .addSum);
	
	initial begin 
	
		inA = 64'd454; inB = 64'd6969; #10000;
		inA = 64'd42069; inB = 64'd69420; #10000;
		inA = 64'hFFFFFFFFFFFFFFFF; inB = 64'd200; #10000;
			
		$stop;
	end
endmodule 
	
	