// Brian Dallaire
// 12/3/2021
// EE 469
// Lab #4

// Test bench for ALU

`timescale 1ns/10ps

// Meaning of signals in and out of the ALU:

// Flags:
// negative: whether the result output is negative if interpreted as 2's comp.
// zero: whether the result output was a 64-bit zero.
// overflow: on an add or subtract, whether the computation overflowed if the inputs are interpreted as 2's comp.
// carry_out: on an add or subtract, whether the computation produced a carry-out.

// cntrl			Operation						Notes:
// 000:			result = B						value of overflow and carry_out unimportant
// 010:			result = A + B
// 011:			result = A - B
// 100:			result = bitwise A & B		value of overflow and carry_out unimportant
// 101:			result = bitwise A | B		value of overflow and carry_out unimportant
// 110:			result = bitwise A XOR B	value of overflow and carry_out unimportant

module alustim();

	parameter delay = 100000;

	logic		[63:0]	A, B;
	logic		[2:0]		cntrl;
	logic		[63:0]	result;
	logic					negative, zero, overflow, carry_out ;

	parameter ALU_PASS_B=3'b000, ALU_ADD=3'b010, ALU_SUBTRACT=3'b011, ALU_AND=3'b100, ALU_OR=3'b101, ALU_XOR=3'b110;
	

	alu dut (.A, .B, .cntrl, .result, .negative, .zero, .overflow, .carry_out);

	// Force %t's to print in a nice format.
	initial $timeformat(-9, 2, " ns", 10);

	integer i;
	logic [63:0] test_val;
	initial begin
	
// *************************************************************************************************************//
// 															Testing PASS_B Operation
// *************************************************************************************************************//
		$display("%t testing PASS_B operations", $time);
		cntrl = ALU_PASS_B;
		for (i=0; i<100; i++) begin
			A = $random(); B = $random();
			#(delay);
			assert(result == B && negative == B[63] && zero == (B == '0));
		end
		
// *************************************************************************************************************//	
// 															Testing ALU_ADD Operation													 //
// *************************************************************************************************************//	
		$display("%t testing addition", $time);
		cntrl = ALU_ADD;
		for(i = 0; i < 64'd2000; i++) begin
			A = $random(); B = $random();
			test_val = A + B;
			#(delay);
			assert(result == test_val && negative == (test_val[63]) && zero == (test_val == '0));
		end
		
		A = 64'd5983028; B = 64'd35789247;
		#(delay);
		assert(result == 64'd41772275 && carry_out == 0 && overflow == 0 && negative == 0 && zero == 0);

		A = 64'hFFFFFFFFFFFFFFFF; B = 64'hFFFFFFFFFFFFFFFF;
		test_val = A + B;
		#(delay);
		assert(result == test_val && carry_out == 1 && overflow == 0 && negative == 1 && zero == 0);
		
		A = 64'hBFFFFFFFFFFFFFFF; B = 64'hBFFFFFFFFFFFFFFF;
		test_val = A + B;
		#(delay);
		assert(result == test_val && carry_out == 1 && overflow == 1 && negative == 0 && zero == 0);
		
		A = 64'h7FFFFFFFFFFFFFFF; B = 64'h7FFFFFFFFFFFFFFF;
		test_val = A + B;
		#(delay);
		assert(result == test_val && carry_out == 0 && overflow == 1 && negative == 1 && zero == 0);
		
		A = 64'h7FFFFFFFFFFFFFFF; B = 64'h7FFFFFFFFFFFFFFF;
		test_val = A + B;
		#(delay);
		assert(result == test_val && carry_out == 0 && overflow == 1 && negative == 1 && zero == 0);
		
		A = 64'h0; B = 64'h0;
		test_val = A + B;
		#(delay);
		assert(result == test_val && carry_out == 0 && overflow == 0 && negative == 0 && zero == 1);
		
// *************************************************************************************************************//
//																Testing ALU_SUBTRACT Operation											 //
// *************************************************************************************************************//

		$display("%t testing subtraction", $time);
		cntrl = ALU_SUBTRACT;
		for(i = 0; i < 64'd2000; i++) begin
			A = $urandom_range(0, 32'hFFFFFFFF); B = $urandom_range(0, 32'hFFFFFFFF);
			test_val = A - B;
			#(delay);
			assert(result == test_val && negative == (test_val[63]) && zero == (test_val == '0));
		end
		
		A = 64'h1100111000010001; B = 64'h1100111000010001;
		test_val = A - B;
		#(delay);
		assert(result == test_val && carry_out == 1 && overflow == 0 && negative == 0 && zero == 1);
		
		A = 64'h7FFFFFFFFFFFFFFF; B = 64'hFFFFFFFFFFFFFFFF;
		test_val = A - B;
		#(delay);
		assert(result == test_val && carry_out == 0 && overflow == 1 && negative == 1 && zero == 0);
		
		A = 64'hBFFFFFFFFFFFFFFF; B = 64'h4FFFFFFFFFFFFFFF;
		test_val = A - B;
		#(delay);
		assert(result == test_val && carry_out == 1 && overflow == 1 && negative == 0 && zero == 0);

		A = 64'h8FFFFFFFFFFFFFFF; B = 64'hBFFFFFFFFFFFFFFF;
		test_val = A - B;
		#(delay);
		assert(result == test_val && carry_out == 0 && overflow == 0 && negative == 1 && zero == 0);		
		
		A = 64'h0; B = 64'h0;
		test_val = A - B;
		#(delay);
		assert(result == test_val && carry_out == 1 && overflow == 0 && negative == (test_val[63]) && zero == 1);
		
		A = 64'd50238; B = 64'd419; 
		test_val = A - B; // equals 64'd49819
		#(delay);
		assert(result == test_val && carry_out == 1 && overflow == 0 && negative == 0 && zero == 0);
		
		A = 64'd14357; B = 64'd3985430;
		test_val = A - B; // equals -3971073
		#(delay);
		assert(result == test_val && carry_out == 0 && overflow == 0 && negative == 1 && zero == 0);


		
// *************************************************************************************************************//	
// 															Testing ALU_AND Operation													 //
// *************************************************************************************************************//

		$display("%t testing bitwise AND operation", $time);
		cntrl = ALU_AND;
		for (i=0; i<1000; i++) begin
			A = $random(); B = $random();
			test_val = A & B;
			#(delay);
			assert(result == test_val && negative == test_val[63] && zero == (test_val == '0));
		end
		
		A = 64'h8000000000000000; B = 64'h8000000000000000;
		test_val = A & B;
		#(delay);
		assert(result == test_val && negative == 1 && zero == 0);
		
		A = 64'h9; B = 64'hC;
		test_val = A & B;
		#(delay);
		assert(result == test_val && negative == 0 && zero == 0);
		
		A = 64'h87954; B = 64'h87654;
		test_val = A & B;
		#(delay);
		assert(result == test_val && negative == 0 && zero == 0);
		
		A = 64'hAAAAAAAAAAAAAAAA; B = 64'h5555555555555555;
		test_val = A & B;
		#(delay);
		assert(result == test_val && negative == 0 && zero == 1);
		
		A = '1; B = '1;
		test_val = A & B;
		#(delay);
		assert(result == test_val && negative == 1 && zero == 0);
		
		A = '0; B = '0;
		test_val = A & B;
		#(delay);
		assert(result == test_val && negative == 0 && zero == 1);

		
// *************************************************************************************************************//	
// 															Testing ALU_OR Operation													 //
// *************************************************************************************************************//

		$display("%t testing bitwise OR operation", $time);
		cntrl = ALU_OR;
		for (i=0; i<1000; i++) begin
			A = $random(); B = $random();
			test_val = A | B;
			#(delay);
			assert(result == test_val && negative == test_val[63] && zero == (test_val == '0));
		end
		
		A = 64'h8000000000000000; B = 64'h8000000000000000;
		test_val = A | B;
		#(delay);
		assert(result == test_val && negative == 1 && zero == 0);
		
		A = 64'hAAAAAAAAAAAAAAAA; B = 64'h5555555555555555;
		test_val = A | B;
		#(delay);
		assert(result == test_val && negative == 1 && zero == 0);
		
		A = '1; B = '1;
		test_val = A | B;
		#(delay);
		assert(result == test_val && negative == 1 && zero == 0);
		
		A = '0; B = '0;
		test_val = A | B;
		#(delay);
		assert(result == test_val && negative == 0 && zero == 1);
		

// *************************************************************************************************************//	
// 															Testing ALU_XOR Operation													 //
// *************************************************************************************************************//

		$display("%t testing bitwise XOR operation", $time);
		cntrl = ALU_XOR;
		for (i=0; i<1000; i++) begin
			A = $random(); B = $random();
			test_val = A ^ B;
			#(delay);
			assert(result == test_val && negative == test_val[63] && zero == (test_val == '0));
		end
		
		A = 64'h8000000000000000; B = 64'h8000000000000000;
		test_val = A ^ B;
		#(delay);
		assert(result == test_val && negative == 0 && zero == 1);
		
		A = 64'h8000000000000000; B = 64'h8000000000000001;
		test_val = A ^ B;
		#(delay);
		assert(result == test_val && negative == 0 && zero == 0);
		
		A = 64'hAAAAAAAAAAAAAAAA; B = 64'h5555555555555555;
		test_val = A ^ B;
		#(delay);
		assert(result == test_val && negative == 1 && zero == 0);
		
		A = '1; B = '1;
		test_val = A ^ B;
		#(delay);
		assert(result == test_val && negative == 0 && zero == 1);
		
		A = '0; B = '0;
		test_val = A ^ B;
		#(delay);
		assert(result == test_val && negative == 0 && zero == 1);	

		A = 64'h9; B = 64'hC;
		test_val = A ^ B;
		#(delay);
		assert(result == test_val && negative == 0 && zero == 0);
	end
endmodule
