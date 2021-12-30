	// Brian Dallaire
// 04/23/2021
// EE 371
// Lab #2, Task 3

// FIFO_Control takes the 1-bit inputs clk, reset, read, and write and outputs the 1-bit outputs wr_en, empty and full
// and outputs the variable-bit outputs readAddr and writeAddr. In this lab, these values are set to 4 bits since the
// global parameter depth is set to 4. The purpose of this module is to control the overall behavior of the FIFO and 
// keep things organized The FIFO_Control makes sure the FIFO behaves a certain way when it is full or empty, and allows
// for data to be written into or read from the RAM. 	

module FIFO_Control #(parameter depth = 4)(clk, reset, read, write, wr_en, empty, full, readAddr, writeAddr);

	input logic clk, reset;
	input logic read, write;
	output logic wr_en;
	output logic empty, full;
	output logic [depth-1:0] readAddr, writeAddr;
							  
	
	logic almost_empty, almost_full; 
	logic readIncr, writeIncr;
	
	assign almost_empty = (writeAddr == readAddr + 1'b1);
	assign almost_full = (readAddr == writeAddr + 1'b1);
	assign wr_en = (write & ~full);
	
	counter rdaddr (.clk, .reset, .incr(readIncr), .out(readAddr));
	counter wraddr (.clk, .reset, .incr(writeIncr), .out(writeAddr));
	
	// this always_comb block implements the finite state machine I made for the FIFO_Control module
	// Depending on the values of read, write, almost_empty, and almost_full, the states will transition
	// between isEmpty, isBetween, and isFull accordingly. Depending on the situation, the increment conditions
	// for the read and write addresses will also change. The 1-bit outputs empty and full depend on the current state
	// the FIFO is in
	enum {isEmpty, isFull, isBetween} ps, ns;
	always_comb begin
		case(ps)
		
		isEmpty : 	begin
							writeIncr = 0;
							readIncr = 0;
							empty = 1;
							full = 0;
							if(!read & write) begin
								writeIncr = 1;
								ns = isBetween;
							end else
								ns = isEmpty;
							
					   end
		
		isBetween : begin
							writeIncr = 0;
							readIncr = 0;
							empty = 0;
							full = 0;
							if(read & !write & almost_empty) begin
								readIncr = 1;
								ns = isEmpty;
							end else if(!read & write & almost_full) begin
								writeIncr = 1;
								ns = isFull;
							end else if(read & !write) begin
								readIncr = 1;
								ns = isBetween;
							end else if(!read & write) begin
								writeIncr = 1;
								ns = isBetween;
							end else begin
								ns = isBetween;
							end
						end
		
		isFull :    begin
							writeIncr = 0;
							readIncr = 0;
							empty = 0;
							full = 1;
							if(read & !write) begin
								readIncr = 1;
								ns = isBetween;
							end else begin
								ns = isFull;
							end
						end
		endcase
	end
	

	// this always_ff block sets the present state to the "isEmpty" state when reset, 
	// and will progress the present state to the next state otherwise every positive
	// edge of the clk.
	always_ff @(posedge clk) begin
		if(reset) begin
				ps <= isEmpty;
		end else begin
				ps <= ns;
		end
	end

endmodule 

// FIFO_Control_testbench tests the expected and unexpected situations of this module. In this simulation,
// I tested to see what happens when the FIFO is completely full, and if we read everything will it be completely
// empty. Then, I also tested to see if there are any issues in the "isBetween" state by reading and writing in 
// those states a few times.

module FIFO_Control_testbench();
	//parameter depth = 4;
	logic clk, reset;
	logic read, write;
	logic wr_en;
	logic empty, full;
	logic [3:0] readAddr, writeAddr;
	
	FIFO_Control #(.depth(4)) dut (.clk, .reset, .read, .write, .wr_en, .empty, .full, .readAddr, .writeAddr);
	
	parameter CLK_Period = 100;
	
	initial begin
		clk <= 1'b0;
		forever #(CLK_Period/2) clk <= ~clk;
	end
	
	initial begin
		reset <= 1;												 @(posedge clk);
		reset <= 0; read <= 0; write <= 0;				 @(posedge clk);
						read <= 1;								 @(posedge clk);
						read <= 0; write <= 1; repeat(20) @(posedge clk);
						read <= 1; write <= 0; repeat(20) @(posedge clk);
						read <= 0; write <= 1; repeat(8)  @(posedge clk);
						read <= 1; write <= 0; repeat(6)  @(posedge clk);

		reset <= 1;												 @(posedge clk);	
		reset <= 0;								  repeat(4)  @(posedge clk);
		$stop;
	end
endmodule 
						
	
	
	