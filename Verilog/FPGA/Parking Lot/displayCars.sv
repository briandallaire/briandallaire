// Brian Dallaire
// 04/14/2021
// EE 371
// Lab #1, Task 3

// displayCars has 1-bit input logic clear and full, and 4-bit input logic ones and tens. It outputs
// an array of 6, 7-bit HEX displays named hexArray. The purpose of this module is to display the outputs
// of the counter from the previous task. For the special cases where inputs clear or full are true, the
// HEX displays display unique letters. For the case for neither clear or full are true, HEX1 and HEX0 will
// display the total number of cars in the parking lot

module displayCars (clear, full, ones, tens, hexArray);
	input logic clear, full;
	input logic [3:0] ones, tens;
	output logic [5:0][6:0] hexArray;
	
	parameter BLANK = 7'b1111111;
	parameter C = 7'b1000110;
	parameter L = 7'b1000111;
	parameter E = 7'b0000110;
	parameter A = 7'b0001000;
	parameter R = 7'b0101111;
	parameter F = 7'b0001110;
	parameter U = 7'b1000001;

	// this always_comb block is designated for the displays HEX5-2. When clear or full are true, HEX5-2
	// will show letters that spell out CLEA or FULL. Otherwise, they will remain blank.
	always_comb begin 
		
		if(clear)
			hexArray[5:2] = {C, L, E, A};
		else if (full)
			hexArray[5:2] = {F, U, L, L};
		else
			hexArray[5:2] = {BLANK, BLANK, BLANK, BLANK};
	end
	
	// this always_comb block is designated for the displays HEX1-HEX0. When clear is true, HEX1 has to display
	// the letter 'R' and HEX0 has to display the number zero. When clear is not true, HEX1 and HEX0 have to display
	// the total number of cars. hexArray[1] corresponds to HEX1 and represents the tens place, and hexArray[0] represents
	// HEX0 and represents the ones place.
	always_comb begin
		if(clear) begin
			hexArray[1] = R;
			hexArray[0] = 7'b1000000;
		end else begin
			case (tens)
			4'b0000: hexArray[1] = 7'b1000000; // 0
			4'b0001: hexArray[1] = 7'b1111001; // 1
			4'b0010: hexArray[1] = 7'b0100100; // 2
			4'b0011: hexArray[1] = 7'b0110000; // 3
			4'b0100: hexArray[1] = 7'b0011001; // 4
			4'b0101: hexArray[1] = 7'b0010010; // 5
			4'b0110: hexArray[1] = 7'b0000010; // 6
			4'b0111: hexArray[1] = 7'b1111000; // 7
			4'b1000: hexArray[1] = 7'b0000000; // 8
			4'b1001: hexArray[1] = 7'b0010000; // 9
			default: hexArray[1] = 7'bX;
			endcase
			case (ones)
			4'b0000: hexArray[0] = 7'b1000000; // 0
			4'b0001: hexArray[0] = 7'b1111001; // 1
			4'b0010: hexArray[0] = 7'b0100100; // 2
			4'b0011: hexArray[0] = 7'b0110000; // 3
			4'b0100: hexArray[0] = 7'b0011001; // 4
			4'b0101: hexArray[0] = 7'b0010010; // 5
			4'b0110: hexArray[0] = 7'b0000010; // 6
			4'b0111: hexArray[0] = 7'b1111000; // 7
			4'b1000: hexArray[0] = 7'b0000000; // 8
			4'b1001: hexArray[0] = 7'b0010000; // 9
			default: hexArray[0] = 7'bX;
			endcase
		end
	end
	
	
endmodule 

// displayCars_testbench tests irregular and regular cases of this module. For this testbench, 
// I saw the effects of what happens when the count goes from zero to over 10. I made the max
// to be 11, so when the count was 11 and full became true, I saw the behaviors of the HEX displays.
// Then I counted back down to 0 and saw the behavior of the HEX displays when it reached zero and
// clear was true.
module displayCars_testbench();

	logic clear, full;
	logic [3:0] ones, tens;
	logic [5:0][6:0] hexArray;
	
	displayCars dut (.clear, .full, .ones, .tens, .hexArray);
	
	initial begin 
	
		clear <= 1; ones <= '0; tens <= '0; #10;
		clear <= 0; ones <= 4'b0001;		   #10;
						ones <= 4'b0010;		   #10;
						ones <= 4'b0011;		   #10;
						ones <= 4'b0100;		   #10;
						ones <= 4'b0101;		   #10;						
						ones <= 4'b0110;		   #10;
						ones <= 4'b0111;			#10;
						ones <= 4'b1000;		   #10;
						ones <= 4'b1001;		   #10;
						ones <= 4'b0000; tens <= 4'b0001;		   #10;
		full <= 1;	ones <= 4'b0001;		   #10;
		full <= 0;  ones <= 4'b0000; 			#10;
						ones <= 4'b1001; tens <= 4'b0000;		   #10;
						ones <= 4'b1000;		   #10;
						ones <= 4'b0111;		   #10;
						ones <= 4'b0110;		   #10;
						ones <= 4'b0101;		   #10;
						ones <= 4'b0100;		   #10;
						ones <= 4'b0011;		   #10;
						ones <= 4'b0010;		   #10;
						ones <= 4'b0001;		   #10;
		clear <= 1;	ones <= 4'b0000;		   #10;

		$stop;
	end
endmodule 