// Brian Dallaire
// 04/14/2021
// EE 371
// Lab #1, Task 4

// DE1_SoC takes a 1-bit input CLOCK_50, 34-bit inout logic GPIO_0, and returns 6 different 7-bit displays HEX5 - HEX0. DE1_SoC combines
// the modules created in the previous tasks, and the LED on the GPIO_0 board and the HEX displays visualize the parking lot.

module DE1_SoC (HEX0, HEX1, HEX2, HEX3, HEX4, HEX5, GPIO_0, CLOCK_50);
 
	input logic CLOCK_50;
	output logic [6:0] HEX0, HEX1, HEX2, HEX3, HEX4, HEX5;
	inout logic [33:0] GPIO_0;
	
	logic reset, sw_aRaw, sw_bRaw;
	assign reset = GPIO_0[5];
	assign sw_aRaw = GPIO_0[7];
	assign sw_bRaw = GPIO_0[9];
	assign GPIO_0[26] = sw_aRaw;
	assign GPIO_0[27] = sw_bRaw;
	
	logic increment, decrement, clearLot, fullLot;
	logic sw_a, sw_b;
	logic [3:0] onePlace, tenPlace;
	
	// series_dffs take a 1-bit CLOCK_50, 1-bit reset, 1-bit sw_aRAW as inputs and output a clean 1-bit sw_a signal. 
	// GPIO_[7] is filtered through two DFFs in series to prevent any chance of metastability
	series_dffs sensor_a (.clk(CLOCK_50), .reset, .raw(sw_aRaw), .clean(sw_a));
	
	// series_dffs take a 1-bit CLOCK_50, 1-bit reset, 1-bit sw_aRAW as inputs and output a clean 1-bit sw_a signal. 
	// GPIO_[9] is filtered through two DFFs in series to prevent any chance of metastability
	series_dffs sensor_b (.clk(CLOCK_50), .reset, .raw(sw_bRaw), .clean(sw_b));
	
	// lotFSM takes a 1-bit CLOCK_50, 1-bit reset, 1-bit sw_a, 1-bit sw_b signals as inputs and outputs 1-bit outputs
	// increment and decrement. The purpose of this module is to determine if the sensors represented by sw_a and sw_b
	// were triggered in the proper order to indicate if a car fully entered or exited the parking lot
	lotFSM pLot (.clk(CLOCK_50), .reset, .a(sw_a), .b(sw_b), .incr(increment), .decr(decrement));
	
	// counter takes 1-bit CLOCK_50, 1-bit reset, 1-bit increment, 1-bit decrement as inputs, and outputs 1-bit clearLot,
	// 1-bit fullLot, 4-bit onePlace, and 4-bit tenPlace. The purpose of this module is to increment or decrement the total number
	// of cars in the parking lot when the input bits increment or decrement are true. It will output the total number using a combination
	// of the 4-bit outputs onePlace and tenPlace
	counter #(.CAPACITY(25)) countCars(.clk(CLOCK_50), .reset, .inc(increment), .dec(decrement), .clear(clearLot), .full(fullLot), .ones(onePlace), .tens(tenPlace));
	
	// for testbench purposes
   // counter #(.CAPACITY(5)) countCars(.clk(CLOCK_50), .reset, .inc(increment), .dec(decrement), .clear(clearLot), .full(fullLot), .ones(onePlace), .tens(tenPlace));
	
	
	// displayCars takes a 1-bit clearLot, 1-bit fullLot, 4-bit onePlace, 4-bit tenPlace as inputs and outputs an array of 6,
	// 7-bit outputs called hexArray that correspond to the 6 HEX displays of the DE1_SoC board. The purpose of this module
	// is to display the total count of cars in the parking lot, and also display when the parking lot is empty of full.
	displayCars dispHEX (.clear(clearLot), .full(fullLot), .ones(onePlace), .tens(tenPlace), .hexArray({HEX5, HEX4, HEX3, HEX2, HEX1, HEX0}));

endmodule 

// DE1_SoC_testbench tests all of the expected and unexpected behavior of the parking lot system. 
// For this testbench, I showcased the situation where a pedestrian walks through the sensors, 
// cars entering the parking lot enough times to reach maximum capacity, and then from there 
// having cars exiting the parking lot enough times to reach an empty lot. 

module DE1_SoC_testbench();

	logic [6:0] HEX0, HEX1, HEX2, HEX3, HEX4, HEX5;
	logic CLOCK_50;
	wire [33:0] GPIO_0;
	
	logic reset, A, B;
	
	DE1_SoC dut (.HEX0, .HEX1, .HEX2, .HEX3, .HEX4, .HEX5, .GPIO_0, .CLOCK_50);
	
	assign GPIO_0[5] = reset;
	assign GPIO_0[7] = A;
	assign GPIO_0[9] = B;

	
	parameter CLOCK_PERIOD=100;
	initial begin
		CLOCK_50 <= 0;
		forever #(CLOCK_PERIOD/2) CLOCK_50 <= ~CLOCK_50; // Forever toggle the clock
	end		
	
	initial begin
	reset <= 1; 									@(posedge CLOCK_50);
	reset <= 0;	A <= 0; B <= 0;				@(posedge CLOCK_50);
	
	
					A <= 1; 				         @(posedge CLOCK_50);
					A <= 0;  B <= 1; 				@(posedge CLOCK_50);
								B <= 0;				@(posedge CLOCK_50);
	repeat(5) begin
					A <= 1;							@(posedge CLOCK_50);
								B <= 1;  			@(posedge CLOCK_50);
					A <= 0;							@(posedge CLOCK_50);
								B <= 0;				@(posedge CLOCK_50);
	end
	
	repeat(5) begin 
								B <= 1;						@(posedge CLOCK_50);
					A <= 1;									@(posedge CLOCK_50);
								B <= 0;						@(posedge CLOCK_50);
					A <= 0;									@(posedge CLOCK_50);
	end
																@(posedge CLOCK_50);
																@(posedge CLOCK_50);
	$stop;
	
	end
	
endmodule 