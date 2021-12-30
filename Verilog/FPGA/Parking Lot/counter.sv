// Brian Dallaire
// 04/14/2021
// EE 371
// Lab #1, Task 2

// counter is a module that takes 1-bit inputs clk, reset, inc, dec and outputs 1-bit outputs
// clear and full, and 4-bit outputs ones and tens. The purpose of this module is to count the
// total number of cars in the parking lot and increment and decrement accordingly 

module counter #(parameter CAPACITY = 25) (clk, reset, inc, dec, clear, full, ones, tens);

	input logic clk, reset, inc, dec;
	output logic clear, full;
	output logic [3:0] ones, tens;
	logic [4:0] totalCars;
	
	
	// this always_ff block counts up when increment is true and totalCars is no the max capacity
	// it also updates ones and tens depending on if one is 9 or 0.
	always_ff @(posedge clk) begin
		if(reset) begin
			totalCars <= '0;
			ones <= '0;
			tens <= '0;

		end else begin
			if(inc & (totalCars != CAPACITY)) begin
				totalCars <= totalCars + 1'b1;
				
				if(ones == 4'b1001) begin
					ones <= '0;
					tens <= tens + 4'b0001;
				end else begin
					ones <= ones + 4'b0001;
				end
				
			end else if (dec & totalCars != 0) begin
				totalCars <= totalCars - 1'b1;
				
				if(ones == 4'b0000) begin
					ones <= 4'b1001;
					tens <= tens - 4'b0001;
				end else begin
					ones <= ones - 4'b0001;
				end
				
			end else begin
				totalCars <= totalCars;
			end
		end
	end
	
	assign clear = (totalCars == 5'b00000);
	assign full = (totalCars == CAPACITY);
	
endmodule 

// counter_testbench tests all expected and unexpected behavior of the count module. The primary purpose of this
// testbench is to see the behavior of the counter when it tries to decrement at 0 or increment at max capacity.
module counter_testbench();

	logic clk, reset, inc, dec;
	logic clear, full;
	logic [3:0] ones, tens;
	
	counter #(.CAPACITY(12)) dut (.clk, .reset, .inc, .dec, .clear, .full, .ones, .tens);
	
	parameter CLOCK_PERIOD = 100;
	initial begin 
		clk <= 0;
		forever # (CLOCK_PERIOD/2) clk <= ~clk; //Forever toggle clock
	end
		
	initial begin
	
		reset <= 1; 							          @(posedge clk);
		reset <= 0; inc <= 1;   			repeat(18) @(posedge clk);
						inc <= 0; dec <= 1;  repeat(18) @(posedge clk);
									 dec <= 0;	repeat(2) @(posedge clk);
		
		$stop;
	end
endmodule 
		