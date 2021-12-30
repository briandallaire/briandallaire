// Brian Dallaire
// 04/23/2021
// EE 371
// Lab #2, Task 1

// displayOrganizer takes the 4-bit inputs dataIn and dataOut and the 5-bit input address and returns
// the 4, 7-bit outputs hexArray. The purpose of this module is to organize everything that needs to 
// be displayed onto the HEX displays.

module displayOrganizer (dataIn, address, dataOut, hexArray);

	input logic [3:0] dataIn, dataOut;
	input logic [4:0] address;
	output logic [3:0][6:0] hexArray;
	
	// seg7hex takes the 4-bit input with 3 bits of zeros + the 4th bit of the address
	// to display the hexadecimal value onto the 4th value of hexArray, which corresponds
	// to HEX5
	seg7hex addr_dispL   (.bcd({3'b000, address[4]}), .leds(hexArray[3]));
	
	// seg7hex takes the 4-bit input which is the first 4 bits of address, and outputs
	// the third value of the hexArray which corresponds to the 7-segment display HEX4
	seg7hex addr_dispR   (.bcd(address[3:0]), .leds(hexArray[2]));
	
	// seg7hex takes the 4-bit input dataIn and outputs the second value of hexArray
	// which corresponds to the 7-segment display HEX1
	seg7hex dataIn_disp  (.bcd(dataIn), .leds(hexArray[1]));
	
	// seg7hex takes the 4-bit input dataOut and outputs the first value of the hexArray
	// which corresponds to the 7-segment display HEX0
	seg7hex dataOut_disp (.bcd(dataOut), .leds(hexArray[0]));
	
	
endmodule 

// displayOrganizer_testbench is a test to see if the 4-bit values dataIn and dataOut and 
// the 5-bit value address all display onto the correct HEX display and display the correct
// hexadecimal value on those displays.

module displayOrganizer_testbench();
	logic [3:0] dataIn, dataOut;
	logic [4:0] address;
	logic [3:0][6:0] hexArray;
	
	displayOrganizer dut (.dataIn, .address, .dataOut, .hexArray);
	
	initial begin
		dataIn <= 3'b001; dataOut <= 3'b110; address <= 4'b0000; #10;
		dataIn <= 3'b011; dataOut <= 3'b101; address <= 4'b0010; #10;
		dataIn <= 3'b010; dataOut <= 3'b111; address <= 4'b0101; #10;
		dataIn <= 3'b110; dataOut <= 3'b000; address <= 4'b1010; #10;
		dataIn <= 3'b111; dataOut <= 3'b001; address <= 4'b0110; #10;
		dataIn <= 3'b101; dataOut <= 3'b010; address <= 4'b1001; #10;
		$stop;
	end
endmodule 