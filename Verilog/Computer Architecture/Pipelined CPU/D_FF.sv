// Brian Dallaire
// 12/3/2021
// EE 469
// Lab #4

// D_FF has the 1-bit inputs d, reset, and clk and has the 1-bit output q. The purpose of this module is to
// represent a D flop flop.

module D_FF (q, d, reset, clk);

	output reg q;
	input d, reset, clk;
	
	always_ff @(posedge clk)
		if (reset)
			q <= 0; // On reset, set to 0
		else
			q <= d; // Otherwise out = d
endmodule 
