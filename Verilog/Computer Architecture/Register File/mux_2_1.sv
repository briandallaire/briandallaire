`timescale 1ps/1ps

module mux_2_1 (select, load, data); 

	input logic select;
	input logic [1:0] load;
	output logic data;
	
	logic notSelect, and1, and2;
	
	
	not #50 notS (notSelect, select);
	
	
	and #50 andgate1 (and1, notSelect, load[0]);
	and #50 andgate2 (and2, select, load[1]);
	
	
	or  #50 or1  (data, and1, and2);
	
endmodule 
	
	
module mux_2_1_testbench();

	logic select;
	logic [1:0] load;
	logic data;
	
	mux_2_1 dut (.select, .load, .data);
	
	initial begin
	
	select = 0; load = 2'b00; #1000;
	select = 1; load = 2'b00; #1000;
	select = 0; load = 2'b01; #1000;
	select = 1; load = 2'b01; #1000;
	select = 0; load = 2'b10; #1000;
	select = 1; load = 2'b10; #1000;
	select = 0; load = 2'b11; #1000;
	select = 1; load = 2'b11; #1000;
	
	$stop;
	end
endmodule 