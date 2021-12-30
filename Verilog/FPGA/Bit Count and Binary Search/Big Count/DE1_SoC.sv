module DE1_SoC (HEX0, HEX1, HEX2, HEX3, HEX4, HEX5, KEY, SW, LEDR, CLOCK_50);

	output logic [6:0] HEX0, HEX1, HEX2, HEX3, HEX4, HEX5;
	output logic [9:0] LEDR;
	input logic [3:0] KEY;
	input logic [9:0] SW;
	input logic CLOCK_50;
	
	assign HEX5 = 7'b1111111;
	assign HEX4 = 7'b1111111;
	assign HEX3 = 7'b1111111;
	assign HEX2 = 7'b1111111;
	assign HEX1 = 7'b1111111;
	
	logic done;
	logic [3:0] result;
	
	bit_count asmd (.clk(CLOCK_50), .reset(~KEY[0]), .s(SW[9]), .data(SW[7:0]), .result, .done);
	seg7 dispCount (.bcd(result), .leds(HEX0));
	
	assign LEDR[9] = done;
	
endmodule 

module DE1_SoC_testbench();

	logic [6:0] HEX0, HEX1, HEX2, HEX3, HEX4, HEX5;
	logic [9:0] LEDR;
	logic [3:0] KEY;
	logic [9:0] SW;
	logic CLOCK_50;
	
	DE1_SoC dut (.HEX0, .HEX1, .HEX2, .HEX3, .HEX4, .HEX5, .KEY, .SW, .LEDR, .CLOCK_50);
	
	parameter CLOCK_PERIOD = 100;
	initial begin 
		CLOCK_50 <= 0;
		forever # (CLOCK_PERIOD/2) CLOCK_50 <= ~CLOCK_50; //Forever toggle clock
	end 
	
	initial begin 
		KEY <= 0; SW[9] <= 0; SW[7:0] <= 8'b01011011;   @(posedge CLOCK_50);
		KEY <= 1; 						  repeat(2)@(posedge CLOCK_50);
						SW[9] <= 1;				 repeat(12)@(posedge CLOCK_50);
						SW[9] <= 0;				  repeat(3)@(posedge CLOCK_50);
		$stop;
	end
endmodule 