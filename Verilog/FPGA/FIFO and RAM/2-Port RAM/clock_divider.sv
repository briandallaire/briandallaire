// Brian Dallaire
// 04/23/2021
// EE 371
// Lab #2, Task 2

// clock_divider takes the 1-bit inputs clk and reset and outputs the 32 bit output
// divided_clocks. The purpose of this module is to slow down the clock that is inputted
// by a specific amount. If the user calls this module and uses divided_clocks[25] for example,
// the outputted clock frequency would be 0.75Hz instead of the 50MHz clock from CLOCK_50.

/* divided_clocks[0] = 25MHz, [1] = 12.5Mhz, ... 
  [23] = 3Hz, [24] = 1.5Hz, [25] = 0.75Hz, ... */
module clock_divider (clk, reset, divided_clocks);
 input logic clk, reset;
 output logic [31:0] divided_clocks = 0;

 // always_ff block that increments divided_clocks by 1. Once divided clocks is full,
 // it will output as one clock cycle. Thus, the bigger the array the slower the clock
 always_ff @(posedge clk) begin
	divided_clocks <= divided_clocks + 1;
 end

endmodule 

// clock_divider_testbench tests the functionality of divided_clocks. It showcases how 
// every increment divided clocks becomes closer to full.

module clock_divider_testbench();
	logic clk, reset;
	logic [31:0] divided_clocks = 0;
	
	clock_divider dut(.clk, .reset, .divided_clocks);
	
	parameter CLOCK_PERIOD=100;
	initial begin
		clk <= 0;
		forever #(CLOCK_PERIOD/2) clk <= ~clk; // Forever toggle the clock
	end
	
	initial begin
		reset <= 1;					@(posedge clk);
		reset <= 0; repeat(2000)@(posedge clk);
		$stop;
	end
endmodule 