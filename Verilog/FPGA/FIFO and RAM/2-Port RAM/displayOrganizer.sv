// Brian Dallaire
// 04/23/2021
// EE 371
// Lab #2, Task 2

// displayOrganizer takes the 4-bit inputs rdData and wrdata and the 5-bit inputs rdaddress and wraddress
// and returns 6, 7-bit outputs called hexArray. The purpose of this module is to organize everything that
// needs to be displayed onto the HEX displays.

module displayOrganizer (rdData, rdaddress, wrdata, wraddress, hexArray);
	
	input logic [3:0] rdData, wrdata;
	input logic [4:0] rdaddress, wraddress;
	output logic [5:0][6:0] hexArray;
	
	logic [3:0] rdaddrL, rdaddrR, wraddrL, wraddrR;
	
	// seg7hex takes the 4-bit input rdData and outputs the first value of hexArray
	// which corresponds to the 7-segment display HEX0
	seg7hex rdData_disp  (.bcd(rdData), .leds(hexArray[0]));
	
	// seg7hex takes the 4-bit input wrdata and outputs the second value of hexArray
	// which corresponds to the 7-segment display HEX1
	seg7hex wrdata_disp  (.bcd(wrdata), .leds(hexArray[1]));
	
	// seg7hex takes the 4-bit input which is the first 4 bits of rdaddress, and outputs
	// the third value of the hexArray which corresponds to the 7-segment display HEX2
	seg7hex rdaddrR_disp (.bcd(rdaddress[3:0]), .leds(hexArray[2]));
	
	// seg7hex takes the 4-bit input with 3 bits of zeros + the 5th bit of rdaddress
	// to display the hexadecimal value onto the fourth value of hexArray, which corresponds
	// to HEX3
	seg7hex rdaddrL_disp (.bcd({3'b000, rdaddress[4]}), .leds(hexArray[3]));
	
	// seg7hex takes the 4-bit input which is the first 4 bits of wraddress, and outputs
	// the fith value of the hexArray which corresponds to the 7-segment display HEX4
	seg7hex wraddrR_disp (.bcd(wraddress[3:0]), .leds(hexArray[4]));
	
	// seg7hex takes the 4-bit input with 3 bits of zeros + the 5th bit of wraddress
	// to display the hexadecimal value onto the fourth value of hexArray, which corresponds
	// to HEX3	
	seg7hex wraddrL_disp (.bcd({3'b000, wraddress[4]}), .leds(hexArray[5]));

endmodule 

// displayOrganizer_testbench is a test to see if the 4-bit values rdData and wrdata and 
// the 5-bit values rdaddress and wraddress all display onto the correct HEX display and 
// display the correct hexadecimal value on those displays.

module displayOrganizer_testbench();
	logic [3:0] rdData, wrdata;
	logic [4:0] rdaddress, wraddress;
	logic [5:0][6:0] hexArray;
	
	displayOrganizer dut (.rdData, .rdaddress, .wrdata, .wraddress, .hexArray); 
	
	initial begin 
		rdData <= 4'b0001; wrdata <= 4'b0010; rdaddress <= 5'b00000; wraddress <= 5'b00000; #10;
		rdData <= 4'b0011; wrdata <= 4'b1110; rdaddress <= 5'b00010; wraddress <= 5'b11111; #10;
		rdData <= 4'b1001; wrdata <= 4'b0110; rdaddress <= 5'b00110; wraddress <= 5'b11000; #10;
		rdData <= 4'b1011; wrdata <= 4'b1011; rdaddress <= 5'b10001; wraddress <= 5'b01010; #10;
		rdData <= 4'b0101; wrdata <= 4'b1111; rdaddress <= 5'b01100; wraddress <= 5'b10101; #10;
		rdData <= 4'b1111; wrdata <= 4'b1010; rdaddress <= 5'b11111; wraddress <= 5'b11011; #10;
		$stop;
	end
endmodule 