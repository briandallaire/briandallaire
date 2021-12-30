// Brian Dallaire
// 04/14/2021
// EE 371
// Lab #1, Task 1

// lotFSM takes 1-bit clk, 1-bit reset, 1-bit a, 1-bit, b as inputs and returns 1-bit incr and 1-bit decr as
// outputs. This module implements the parking lot FSM designed to detect when a car enters or exits the parking
// lot. When a car fully enters the parking lot, the 1-bit output incr will return true, and when a car fully exits
// the parking lot, the 1-bit output will return false.

module lotFSM (clk, reset, a, b, incr, decr);

	input logic clk, reset, a, b;
	output logic incr, decr;

	enum {empty, enter1, enter2, enter3, exit1, exit2, exit3} ps, ns;
	
	// This always_comb block uses the seven enumerated states from the FSM designed for the parking lot and uses the
	// 1-bit inputs a and b to determine the next state in the FSM. A case statement is used to easily transition the 
	// FSM I designed into SystemVerilog code.
	
	always_comb begin 
		case(ps)
		
		empty  : begin
						if(a & !b) 		 ns = enter1;
						else if(!a & b) ns = exit1;
						else				 ns = empty;
					end
					
		enter1 : begin
						if(!a & b | !a & !b) ns = empty;
						else if(a & b) ns = enter2;
						else				 ns = enter1;
					end
					
		enter2 : begin
						if(!a & b) 		 ns = enter3;
						else if(a & !b) ns = enter1;
						else				 ns = enter2;
					end
					
		enter3 : begin
						if(!a & !b)		 ns = empty;
						else if (a & b) ns = enter2;
						else				 ns = enter3;
					end
					
		exit1  : begin
						if(!a & !b | a & !b) ns = empty;
						else if(a & b) ns = exit2;
						else				 ns = exit1;
					end
					
		exit2  : begin
						if(a & !b)      ns = exit3;
						else if (!a & b)ns = exit1;
						else 				 ns = exit2;
					end
					
		exit3  : begin
						if(a & b)     ns = exit2;
						else if(!a & !b)  ns = empty;
						else  ns = exit3;
					end
				
		endcase 
	end
	
	// car fully enters the parking lot
	assign incr = (ps == enter3 & ns == empty);
	
	// car fully exits the parking lot
	assign decr = (ps == exit3 & ns == empty);

	
	// This always_ff block is used to reset the present state of the FSM to the "empty" state when reset is true,
	// and to update the present state to the next state every positive edge of the clock when reset is false.
	always_ff @(posedge clk) begin
		if(reset) begin
			ps <= empty;

		end else begin
			ps <= ns;
		end
	end	

endmodule 

// lotFSM_testbench tests multiple important situations of this module. It tests the behavior of the outputs
// for outliar cases and regular cases. For example, the first test tests if a pedestrian walks by the sensors
// and the next two tests are if a car enters and exits the parking lot multiple times.
module lotFSM_testbench();

	logic clk, reset, a, b, incr, decr;
	
	lotFSM dut (.clk, .reset, .a, .b, .incr, .decr);
	
	parameter CLOCK_PERIOD=100;
	initial begin
		clk <= 0;
		forever #(CLOCK_PERIOD/2) clk <= ~clk; // Forever toggle the clock
	end
	
	initial begin 
		reset <= 1;						  @(posedge clk);
		reset <= 0; a <= 0;	b <= 0; @(posedge clk);
						a <= 1;  		  @(posedge clk);
						a <= 0;	b <= 1; @(posedge clk);
						a <= 0;	b <= 0; @(posedge clk);
						
		repeat(2) begin
						a <= 1;  		  @(posedge clk);
									b <= 1; @(posedge clk);
						a <= 0;  		  @(posedge clk);
						a <= 0;  b <= 0; @(posedge clk);
		end
						a <= 0;	b <= 0; @(posedge clk);
						
		repeat(2) begin
						         b <= 1; @(posedge clk);
						a <= 1;			  @(posedge clk);
									b <= 0; @(posedge clk);
						a <= 0;			  @(posedge clk);
		end
						a <= 0;	b <= 0; @(posedge clk);
		$stop;
	end
endmodule
	
	