// Brian Dallaire
// 05/16/2021
// EE 371
// Lab #4, Task 2

// binary_search takes the 1-bit inputs clk, reset, start and the 8-bit input valueIn and outputs the 
// 5-bit output addrOut and the 1-bit outputs found, notfound, and hide. The main purpose of this module
// is to recursively search through the RAM unit to see if a value equivalent to valueIn is within the 
// RAM. If it is in the RAM, found will return true as well as the address of the value from the RAM.
// If it is not in the RAM, notfound will return true and hide will remain true, keeping any displays
// to remain off. 

module binary_search(clk, reset, start, valueIn, addrOut, found, notfound, hide);

	input logic clk, reset, start;
	input logic [7:0] valueIn;
	output logic [4:0] addrOut;
	output logic found, notfound, hide;
	
	logic [5:0] first, last, middle;
	logic [4:0] middle2;
	logic [7:0] q;
	
	// assigns the middle pointer to (first + last) / 2
	assign middle = (first + last) >> 1;
	
	// ram32x8 takes the 1-bit inputs clk and wren and the 8 bit input data and the 5-bit inputs 
	// rdaddress and wraddress and outputs the 8-bit output q. The main purpose of this module is
	// that it is the RAM unit used in task 2 and contains the values from the MIF file. data, 
	// wraddress, and wren are all set to zero and this is purely a read only RAM unit.
	ram32x8 sortedRam (.clock(~clk), .data(8'b0), .rdaddress(middle[4:0]), .wraddress(5'b0), .wren(1'b0), .q);
	
	enum {stop, search, done} ps, ns;
	
	// this always comb block implements the FSM used for the binary search algorithm. It has
	// three states and only proceeds to search during the "search" state. The 1-bit input start
	// determines if it stays or moves from the states stop and done.
	always_comb begin 
		case(ps) 
		stop   :  if(start) ns = search;
					 else      ns = stop;
		
		search :  if(found | notfound)
								  ns = done;
					 else      ns = search;
		
		done   : if(start) ns = done;
					else      ns = stop;
		endcase
	end
	
	// this always_ff block is used to move the present state to the next state every clock
	// cycle. If reset is true, it will set the present state to the initial state which is
	// the "stop" state.
	always_ff @(posedge clk) begin
		if(reset) 
			ps <= stop;
		else
			ps <= ns;
	end
	
	// this always_ff block is the datapath circuit for the binary search algorithm. When reset,
	// the values of first and last will be set to 0 and 31, making the middle pointer 15. While
	// the next state is search, it will progress through the binary search and eventually end the
	// search, making either found or notfound true. When found is true, hide will be false and the
	// current address for the middle pointer will be assigned to the output addrOut.
	always_ff @(posedge clk) begin
		if(reset || (ps == done && ns == stop)) begin
			first <= '0;
			last  <= 6'b011111;
			found <= 0;
			notfound <= 0;
			hide <= 1;
		end else if(ns == search) begin
			if(valueIn == q) begin
				found <= 1;
				addrOut <= middle[4:0];
				hide <= 0 	;
			end else if(middle == middle2) begin
				notfound <= 1;
			end else if(first == 6'd30 && valueIn > q) begin
				first <= 6'd31;
			end else if(valueIn > q) begin
				first <= middle;
			end else begin
				last <= middle;
			end
			middle2 <= middle[4:0];

		end else begin
			first <= first;
			last <= last;
			found <= found;
			notfound <= notfound;
		end
	end
endmodule 

// binary_search_testbench tests multiple cases to see if the binary search algorithm works properly.
// This testbench assumes that the MIF file increments by 1 and starts from 0 and ends at the value 32.
// It tests cases where the input value is 0 and 33, and cases where the value is above 15 and below 15,
// but within the boundaries of the RAM unit. 

`timescale 1 ps / 1 ps
module binary_search_testbench();

	logic clk, reset, start;
	logic [7:0] valueIn;
	logic [4:0] addrOut;
	logic found;
	logic notfound;
	logic hide;
	
	binary_search dut (.clk, .reset, .start, .valueIn, .addrOut, .found, .notfound, .hide);
	
	parameter CLOCK_PERIOD = 100;
	initial begin 
		clk <= 0;
		forever # (CLOCK_PERIOD/2) clk <= ~clk; //Forever toggle clock
	end 
	
	initial begin 
		reset <= 1; start <= 0; valueIn <= 8'b00000000; 			  @(posedge clk);	
		reset <= 0;									  				repeat(2)  @(posedge clk);
						start <= 1;					 				repeat(10) @(posedge clk);
						start <= 0; valueIn <= 8'b00100001; repeat(2)  @(posedge clk);
						start <= 1;									repeat(10) @(posedge clk);
						start <= 0; valueIn <= 8'b00011001; repeat(2)  @(posedge clk);
						start <= 1;									repeat(10) @(posedge clk);
						start <= 0; valueIn <= 8'b00000101; repeat(2)  @(posedge clk);
						start <= 1;									repeat(10) @(posedge clk);
						
	$stop;
	end
endmodule 
	
