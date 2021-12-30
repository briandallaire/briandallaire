// Brian Dallaire
// 12/3/2021
// EE 469
// Lab #4

// bitALU takes the 1-bit inputs Ain, Bin, and Cin and the 3-bit input select
// and outputs the 1-bit outputs Cout and ALU_out. The purpose of this module
// is to represent a bit slice of the overall 64-bit ALU. The theory is if this
// bit slice ALU works perfectly, instantiating it 64 times would make the 
// 64-bit ALU function properly.

`timescale 1ps/1ps

module bitALU (Ain, Bin, Cin, select, Cout, ALU_out);

	input logic Ain, Bin, Cin;
	input logic [2:0] select;
	output logic Cout, ALU_out;
	
	// logic used to connect logic to each other and connect signals to the 8:1 mux
	logic notBin, muxBin, adderOut;
	logic andAB, orAB, xorAB;
	
	// inverter gate for signal Bin
	not #50 notB_in (notBin, Bin);
	
	// 2:1 mux used to determine if B or !B should be inputted into the Adder
	mux_2_1 muxSubtr(.select(select[0]), .load({notBin, Bin}), .data(muxBin));
	
	// fullAdder is used to either add or subtract the values of Ain and Bin and
	// output the sum/difference into the 8:1 mux. It also takes a carry in and
	// outputs a carry out.
	fullAdder adder (.A(Ain), .B(muxBin), .Cin(Cin), .S(adderOut), .Cout(Cout));
	
	// AND gate used for the bitwise AND operation
	and #50 andGate (andAB, Ain, Bin);
	
	// OR gate used for the bitwise OR operation
	or #50 orGate	 (orAB, Ain, Bin);
	
	// XOR gate used for the bitwise XOR operation
	xor #50 xorGate (xorAB, Ain, Bin);
	
	// this 8:1 mux uses the 3-bit input select as the select bits and the 6 total inputs within the bitslice ALU
	// as well as a couple filler inputs to total 8-inputs. Using the select bits, it decides what the ALU should output.
	mux_8_1 muxOperate (.selectBits(select), .inputs({1'b0, xorAB, orAB, andAB, adderOut, adderOut, 1'b0, Bin}), .muxOut(ALU_out));
	
endmodule 

// bitALU_testbench tests for the expected and unexpected behaviors of this module. For this testbench,
// I tested all combinations of Ain, Bin, and Cin, and for each combination I tested all combinations of
// the select bits. This way if there are no unexpected behaviors then this module functions with 
// all combinations of the inputs

module bitALU_testbench();
	logic Ain, Bin, Cin;
	logic [2:0] select;
	logic Cout, ALU_out;
	
	bitALU dut (.Ain, .Bin, .Cin, .select, .Cout, .ALU_out);
	
	int i, j;
	
	initial begin
		for(i = 0; i < 8; i++) begin
			Ain = i[2]; Bin = i[1]; Cin = i[0]; 
			for(j = 0; j < 8; j++) begin
				select[2] = j[2];
				select[1] = j[1];
				select[0] = j[0]; #5000;
			end
		end
		$stop;
	end
	
endmodule 