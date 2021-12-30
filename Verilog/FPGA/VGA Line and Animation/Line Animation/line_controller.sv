// Brian Dallaire
// 05/07/2021
// EE 371
// Lab 3 Task 2

// line_controller takes the 1-bit inputs clk, reset, and done and outputs the 1-bit output start,
// the 11-bit outputs x0, x1, y0, and y1, and the 1-bit output pixel_color. The main purpose of this
// module is to send to the VGA display and line_drawer the initial and final coordinates and the 
// pixel color. Addtionally, it will reset line_drawer using the "start" variable. Essentially,
// this module acts as a system that automatically goes through many coordinates to draw and erase
// many lines to form an animation. The goal is to form an animation where the line stretched out
// to both edges goes in circles, clockwise. 

module line_controller (clk, reset, done, start, x0, x1, y0, y1, pixel_color);
	
	input logic clk, reset, done;
	output logic start;
	output logic [10:0] x0, x1, y0, y1;
	output logic pixel_color;
	
	logic stepx, stepy, flip;
	
	enum {eraseLine, horizontal, vertical} ps, ns;
	
	// this always_comb block takes the states eraseLine, horizontal, and vertical and updates specific
	// variables to achieve desired behavior. eraseLine is the core of this block, as it has the most
	// conditions and determines the most complex behaviors of the animation. When in eraseLine, pixel
	// color is 0, so the current line that was just drawn is erased. When in horizontal, the line moves
	// clockwise against the top and bottom walls of the display, only requiring x values to increment.
	// When in vertical, the line moves clockwise against the left and right walls, only requiring the
	// y values to change. Going through these states will form the desired animation behavior.
	always_comb begin
		case(ps)
		
			eraseLine    : begin 
									if(done & (x0 != 11'b01010000000) & !start) begin	
										pixel_color = 1'b0;
										flip = 1'b0;
										stepx = 1'b1;
										stepy = 1'b0;
										ns = horizontal;
									end else if (done & (x0 == 11'b01010000000) & (y0 != 11'b00111100000) & !start) begin
										pixel_color = 1'b0;
										flip = 1'b0;
										stepx = 1'b0;
										stepy = 1'b1;
										ns = vertical;
									end else if (done & (y0 == 11'b00111100000) & (x0 == 11'b01010000000) & !start) begin
										pixel_color = 1'b0;
										flip = 1'b1;
										stepx = 1'b1;
										stepy = 1'b0;
										ns = horizontal;
									end else begin
										pixel_color = 1'b0;
										flip = 1'b0;
										stepx = 1'b0;
										stepy = 1'b0;
										ns = eraseLine;
									end
								end
										
		horizontal     :  begin	
									pixel_color = 1'b1;
									flip  = 1'b0;
									stepx = 1'b0;
									stepy = 1'b0;
									if(done & !start)
										ns = eraseLine;
									else
										ns = horizontal;
								end
						
		vertical       :  begin
									pixel_color = 1'b1;
									flip  = 1'b0;
									stepx = 1'b0;
									stepy = 1'b0;
									if(done & !start)
										ns = eraseLine;
									else
										ns = vertical;
								end
	
		endcase
	end
	
	// this always_ff block is used to increment multiple values and change the present state. When reset,
	// the coordinates will update to the original position. When the animation makes a full cirlce, 
	// the values for (x0, y0) and (x1, y1) need to be flipped to keep the system simple. Otherwise,
	// every time a line is done, it will increment the coordinates accordingly. Whenever done or reset is
	// true, start will be true. This will reset the line_drawer module. If reset and done are not true, 
	// the coordinates remain the same and line_drawer will continue to behave as normal.
	always_ff @(posedge clk) begin
		if(reset) begin
			ps <= eraseLine;
			x0 <= 11'b00000000001; // 1;
			y0 <= 11'b00000000000; // 0;
			x1 <= 11'b01001111111; // 639
			y1 <= 11'b00111100000; // 480
			start <= 1;
		end else begin
			if(flip & done) begin
				x0 <= 11'b00000000001;
				y0 <= 11'b00000000000;
				x1 <= 11'b01001111111;
				y1 <= 11'b00111100000;
				start <= 1;
			end else if (done) begin
				x0 <= x0 + stepx;
				y0 <= y0 + stepy;
				x1 <= x1 - stepx;
				y1 <= y1 - stepy;
				start <= 1;
			end else begin
				x0 <= x0;
				y0 <= y0;
				x1 <= x1;
				y1 <= y1;
				start <= 0;
			end
			
			ps <= ns;
			
		end
	end				
endmodule 

// line_controller_testbench tests the expected and unexpected cases for this module and if the system
// cycles through properly. Because ther are no inputs other than reset and done that can be toggled
// manually, I simply toggled reset once, then toggled done 4000 times to make sure the animation reaches
// full circle. The cases to look for were when the state transitioned from horizontal to vertical, then
// vertical back to horizontal when flip is true. 
module line_controller_testbench();
	logic clk, reset, done;
	logic start;
	logic [10:0] x0, x1, y0, y1;
	logic pixel_color;
	
	line_controller dut(.clk, .reset, .done, .start, .x0, .x1, .y0, .y1, .pixel_color);
	
	parameter clock_period = 100;
	
	initial begin
		clk <= 0;
		forever #(clock_period /2) clk <= ~clk;
	end
	initial begin
		reset <= 1; done <= 0; @(posedge clk);
		repeat(4000) begin
		reset <= 0; done <= 0; repeat(2)@(posedge clk);
		reset <= 0; done <= 1; @(posedge clk);
		end
		reset <= 1; @(posedge clk);
		reset <= 0; repeat(20)@(posedge clk);
		$stop;
	end
endmodule 
