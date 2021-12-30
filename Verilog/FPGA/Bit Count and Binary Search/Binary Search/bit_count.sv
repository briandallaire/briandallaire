module bit_count(clk, reset, s, data, result, done);
	input logic clk, reset, s;
	input logic [7:0] data;
	output logic [3:0] result;
	output logic done;
	
	logic [7:0] A;
	
	enum {s1, s2, s3} ps, ns;
	
	always_comb begin 
		case(ps)
		
		s1 : if(!s) ns = s1;
 			  else   ns = s2;
			  
		s2 : if(A==0) ns = s3;
			  else 	  ns = s2;
		
		s3 : if(s) ns = s3;
			  else ns = s1;
		endcase
	end 
	
	always_ff @(posedge clk) begin
		if(reset || ((ns == s1) && (ps == s3))) begin 
			result <= 0;
			done <= 0;
			ps <= s1;
		end else begin 
			if(ps == s1 & ns == s1) begin 
				A <= data;
				result <= 0;
			end else if(ns==s2 & A[0] == 1) begin
				result <= result + 1'b1;
				A <= (A >> 1);
			end else if(ns == s2 & A[0] == 0) begin
				result <= result;
				A <= (A >> 1);
			end else if (ns == s3) begin 
				done <= 1;
			end 
			ps <= ns;
		end
	end
endmodule
	
module bit_count_testbench();

	logic clk, reset, s;
	logic [7:0] data;
	logic [3:0] result;
	logic done;

	bit_count dut (.clk, .reset, .s, .data, .result, .done);
	
	parameter CLOCK_PERIOD = 100;
	initial begin 
		clk <= 0;
		forever # (CLOCK_PERIOD/2) clk <= ~clk; //Forever toggle clock
	end 
	
	initial begin 
		reset <= 1; s <= 0; data <= 8'b01011011; @(posedge clk);
		reset <= 0; 						  repeat(2)@(posedge clk);
						s <= 1;				 repeat(12)@(posedge clk);
						s <= 0;				  repeat(3)@(posedge clk);
		$stop;
	end
endmodule 