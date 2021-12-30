// Brian Dallaire
// 04/23/2021
// EE 371
// Lab #2, Task 1

// RAM32_4 takes the 1-bit inputs clk and write, 4-bit input dataIn, 5-bit input address, and outputs the 
// 4-bit output dataOut. The main purpose of this module is to represent a 32x4 single-port RAM using 
// SystemVerilog code. 

module RAM32_4 (clk, write, dataIn, address, dataOut);

	input logic clk, write;
	input logic [3:0] dataIn;
	input logic [4:0] address;
	output logic [3:0] dataOut;
	
	logic [3:0] memory_array [31:0];

	// this always_ff block uses the intermediate logic memory_array to
	// implement the 32x4 RAM unit. Every clock cycle, it will "read"
	// the value at each address by assigning dataOut the 4-bit data 
	// inside the 32-bit array, where the location of each data is determined
	// by the address. If write is true, it will also rewrite a new data 
	// determined by dataIn into the address of the memory_array.
	always_ff @(posedge clk) begin
		dataOut <= memory_array[address];
		if(write)
			memory_array[address] <= dataIn;
	end
	
endmodule

// RAM32_4_testbench tests both the expected and unexpected situations of this module. In this simulation,
// I do a writing operation on many addresses, then read all of the values written into those addresses 
// with a reading operation. Then, I try rewriting a few of those addresses to test if the RAM can be rewritten
// more than once in a specific address. 

module RAM32_4_testbench();
	logic clk, write;
	logic [3:0] dataIn;
	logic [4:0] address;
	logic [3:0] dataOut;
	
	RAM32_4 dut (.clk, .write, .dataIn, .address, .dataOut);
	
	parameter CLOCK_PERIOD=100;
	initial begin
		clk <= 0;
		forever #(CLOCK_PERIOD/2) clk <= ~clk; // Forever toggle the clock
	end
	
	initial begin
		//writing operation
		address <= 5'b00000; dataIn <= 4'b0001; write <= 1; @(posedge clk);
		address <= 5'b00001; dataIn <= 4'b0011; write <= 1; @(posedge clk);
		address <= 5'b00100; dataIn <= 4'b0101; write <= 1; @(posedge clk);
		address <= 5'b01110; dataIn <= 4'b1001; write <= 1; @(posedge clk);
		address <= 5'b11000; dataIn <= 4'b1111; write <= 1; @(posedge clk);
		address <= 5'b10101; dataIn <= 4'b1101; write <= 1; @(posedge clk);
		address <= 5'b01010; dataIn <= 4'b0100; write <= 1; @(posedge clk);
		address <= 5'b11111; dataIn <= 4'b1000; write <= 1; @(posedge clk);
		
		//reading operation
		address <= 5'b00000; dataIn <= 4'b0000; write <= 0; @(posedge clk);
		address <= 5'b00001; dataIn <= 4'b0001; write <= 0; @(posedge clk);
		address <= 5'b00100; dataIn <= 4'b0001; write <= 0; @(posedge clk);
		address <= 5'b01110; dataIn <= 4'b1001; write <= 0; @(posedge clk);
		address <= 5'b11000; dataIn <= 4'b1111; write <= 0; @(posedge clk);
		address <= 5'b10101; dataIn <= 4'b1101; write <= 0; @(posedge clk);
		address <= 5'b01010; dataIn <= 4'b0100; write <= 0; @(posedge clk);
		address <= 5'b11111; dataIn <= 4'b1000; write <= 0; @(posedge clk);
		
		//rewriting operation
		address <= 5'b00001; dataIn <= 4'b1001; write <= 1; @(posedge clk);
		address <= 5'b11000; dataIn <= 4'b0101; write <= 1; @(posedge clk);
		//rereading operation
		address <= 5'b00001; dataIn <= 4'b1000; write <= 0; @(posedge clk);
		address <= 5'b11000; dataIn <= 4'b0000; write <= 0; @(posedge clk);
																 repeat(3)@(posedge clk);
		$stop;
	end
endmodule 
