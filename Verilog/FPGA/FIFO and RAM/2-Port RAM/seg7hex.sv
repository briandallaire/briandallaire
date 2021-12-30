// Brian Dallaire
// 04/23/2021
// EE 371
// Lab #2, Task 2

// seg7hex takes a 4-bit input bcd and outputs a 7-bit output leds. This module takes the 4-bit input that refers to
// either the data or address that is supposed to be displayed onto a 7-segment HEX display. The name seg7hex means
// that the purpose of this module is to convert the 4-bit input into a hexadeicmal value on the HEX displays.

module seg7hex (bcd, leds);
	input logic [3:0] bcd;
	output logic [6:0] leds;
	
	// this always_comb block uses the 4-bit input bcd as a case, and returns the value of leds in a way that
	// displays the hexadecimal value of the 4-bit input. It is clearly visible that all of the one digit
	// hexadecimal values are covered from 0 - F
	
	always_comb begin
	
		case (bcd)
		
		4'b0000: leds = 7'b1000000; // 0
		4'b0001: leds = 7'b1111001; // 1
		4'b0010: leds = 7'b0100100; // 2
		4'b0011: leds = 7'b0110000; // 3
		4'b0100: leds = 7'b0011001; // 4
		4'b0101: leds = 7'b0010010; // 5
		4'b0110: leds = 7'b0000010; // 6
		4'b0111: leds = 7'b1111000; // 7
		4'b1000: leds = 7'b0000000; // 8
		4'b1001: leds = 7'b0010000; // 9
		4'b1010: leds = 7'b0001000; // A
		4'b1011: leds = 7'b0000011; // B
		4'b1100: leds = 7'b1000110; // C
		4'b1101: leds = 7'b0100001; // D
		4'b1110: leds = 7'b0000110; // E
		4'b1111: leds = 7'b0001110; // F
		default: leds = 7'bX;
		
		endcase
		
	end
	
endmodule 

// seg7hex_testbench tests all of the cases of the 4-bit input bcd and tests to see if the output
// leds correspond to the hexadecimal value in the HEX display. The only thing to test for in this
// testbench is to go through all of the cases.

module seg7hex_testbench();
	logic [3:0] bcd;
	logic [6:0] leds;
	
	seg7hex dut (.bcd, .leds);
	
	initial begin
		bcd <= 4'b0000; #10;
		bcd <= 4'b0001; #10;
		bcd <= 4'b0010; #10;
		bcd <= 4'b0011; #10;
		bcd <= 4'b0100; #10;
		bcd <= 4'b0101; #10;
		bcd <= 4'b0110; #10;
		bcd <= 4'b0111; #10;
		bcd <= 4'b1000; #10;
		bcd <= 4'b1001; #10;
		bcd <= 4'b1010; #10;
		bcd <= 4'b1011; #10;
		bcd <= 4'b1100; #10;
		bcd <= 4'b1101; #10;
		bcd <= 4'b1110; #10;
		bcd <= 4'b1111; #10;
		$stop;
	end
endmodule 