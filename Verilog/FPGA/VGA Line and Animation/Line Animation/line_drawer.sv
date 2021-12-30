// Brian Dallaire
// 05/07/2021
// EE 371
// Lab 3 Task 2

// line_drawer takes the 1-bit inputs clk and reset and 11-bit inputs x0, y0, x1, and y1 and
// outputs the 11-bit outputs x and y and 1-bit output done. This module is used to draw a
// line in a VGA display using the x0, y0, x1, and y0 inputs as (x,y) coordinates. By having
// two coordinates in different locations, a line will be drawn. This is done by first calculating
// the change in x coordinates and y coordinates. Then, it will be determined if the slope is
// "steep" to see if the dx and dy values need to be flipped. Once this is done, the error will
// be calculated to determine the offset in pixels when drawing the line. Lastly, after the error
// is calculated, the output x and y values will be updated accordingly. By repeating this action
// starting from x0 y0, x and y reach the values of x1 and y1 and the line will stop drawing.

module line_drawer(
	input logic clk, reset,
	
	// x and y coordinates for the start and end points of the line
	input logic [10:0]	x0, x1, 
	input logic [10:0] y0, y1,

	//outputs cooresponding to the coordinate pair (x, y)
	output logic [10:0] x,
	output logic [10:0] y, 
	output logic done
	);
	

	logic signed [11:0] err, err_Next, err_Val, err_Temp;
	logic [10:0] xa, xb, dx, deltax, xval, next_x;
	logic [10:0] ya, yb, dy, deltay, yval, next_y, step_y;
	logic [10:0] is_steep;
	//logic [10:0] step_x;

	// this always_comb block is the core of the functionality of this module. Here there are
	// five major components. The first component is determining dx and dy. First, change in x
	// and change in y are determined. If change in y is greater than change in x, the slope is
	// "steep". If the slope is "steep" dx is assigned change in y and dy is assigned change in x.
	// Otherwise, dx is change in x and dy is change in y. The next component simply assigns the first
	// and last values of x and y and can be change depending on conditions such as if "steep" is true
	// or x1>x0, etc. The third component is calculating the error. Since there are a limited number of
	// pixels, the error determines how the pixels are distributed to form the straightest line. Thus,
	// in the fourth component, the increments for updating the outputs x and y are determined using
	// the error from the third component. Lastly, in the fifth component, the outputs x and y are
	// updated using the combination of every component so far. 
	always_comb begin
		deltax   = (x1 > x0) ? (x1 - x0) : (x0 - x1);
		deltay   = (y1 > y0) ? (y1 - y0) : (y0 - y1);
		is_steep = (deltay > deltax);
		dx = !(is_steep) ? deltax : deltay;
		dy = !(is_steep) ? deltay : deltax;
		
		xa = (!is_steep & (x1<x0)) ? x1 : (!is_steep & (x1>x0)) ? x0 : (is_steep & (y1<y0)) ? y1 : y0;
		xb = (!is_steep & (x1<x0)) ? x0 : (!is_steep & (x1>x0)) ? x1 : (is_steep & (y1<y0)) ? y0 : y1;
		ya = (!is_steep & (x1<x0)) ? y1 : (!is_steep & (x1>x0)) ? y0 : (is_steep & (y1<y0)) ? x1 : x0;	
		yb = (!is_steep & (x1<x0)) ? y0 : (!is_steep & (x1>x0)) ? y1 : (is_steep & (y1<y0)) ? x0 : x1;
		
		
//		xa = !(is_steep) ? x0 : y0; 
//		xb = !(is_steep) ? x1 : y1;
//		ya = !(is_steep) ? y0 : x0;
//		yb = !(is_steep) ? y1 : x1;
		
		
		err_Temp = -(dx/2);
		err_Val = err + dy;
		err_Next = (err_Val >= 0) ? err_Val - dx : err_Val;
		
		step_y = (ya < yb) ? 1 : -1;
	   //step_x = (xa < xb) ? 1: -1;
		
		next_x = xval + 1'b1;
		//next_x = xval + step_x;
		next_y = (err_Val >= 0) ? yval + step_y : yval;
		
		x = !(is_steep) ? xval : yval;
		y = !(is_steep) ? yval : xval;
	end
	
	// this always_comb block is what updates the line every clock cycle. xval, yval, and err are
	// being updated depending on the condition of the line. If reset is true, xval and yval are
	// assigned to be the first x value and the first y value. It is set this way since depending 
	// on the coordinates given it is not simply xval <= x0 and yval <= y0. Next, if xval and yval
	// equal the second x value and second y value, then xval, yval, and err remain the same. This 
	// indicates the line is done. If xval and yval dont equal their respective second values, 
	// xval, yval, and err are updated to be variables calculated in the always_comb block. This way,
	// xval, yval, and err are incremented or decremented accordingly. Additionally, "done" is true 
	// when xb == xval and yb == yval. This indicates the line has finished drawing, or reached the end
	always_ff @(posedge clk) begin
		if(reset) begin
			xval <= xa;
			yval <= ya;
			err  <= err_Temp;
			done <= 0;
		end else begin
			if(((xb == xval) && (yb == yval))) begin
				xval <= xval;
				yval <= yval;
				err  <= err;
				done <= 1;
			end else begin
				xval <= next_x;
				yval <= next_y;
				err  <= err_Next;
				done <= 0;
			end
		end
	end
endmodule

// line_drawer_testbench tests the expected and unexpected cases for this module. For this simulation,
// I tested what happens when the line is drawn diagonally, horizontally, and vertically. I also tested 
// weird cases such as when x0 y0 and x1 y1 are making a "negative" slope. I went one step further and
// tested to see if flipping the coordinates will screw up the values.
module line_drawer_testbench();
	logic clk, reset;
	
	// x and y coordinates for the start and end points of the line
	logic [10:0]	x0, x1; 
	logic [10:0] y0, y1;

	//outputs cooresponding to the coordinate pair (x, y)
	logic [10:0] x;
	logic [10:0] y;
	
	line_drawer dut(.clk, .reset, .x0, .x1, .y0, .y1, .x, .y);
	
	parameter clock_period = 100;
	
	initial begin
		clk <= 0;
		forever #(clock_period /2) clk <= ~clk;
	end
	
	initial begin
		x0 <= 11'd10; x1 <= 11'd25;
	   y0 <= 11'd100; y1 <= 11'd100;
	   reset <= 1;                                   @(posedge clk);
	   reset <= 0;                                   @(posedge clk);                           	
		repeat(20)                                    @(posedge clk);
		x0 <= 11'd100; x1 <= 11'd100;
	   y0 <= 11'd20; y1 <= 11'd30;
	   reset <= 1;                                   @(posedge clk);
	   reset <= 0;                                   @(posedge clk);
		repeat(12)												 @(posedge clk);
		x0 <= 11'd100; x1 <= 11'd110;
	   y0 <= 11'd100; y1 <= 11'd110;
	   reset <= 1;                                   @(posedge clk);
	   reset <= 0;                                   @(posedge clk);
		repeat(20)												 @(posedge clk);
		x0 <= 11'd200; x1 <= 11'd190;
	   y0 <= 11'd200; y1 <= 11'd190;
	   reset <= 1;                                   @(posedge clk);
	   reset <= 0;                                   @(posedge clk);
		repeat(20)												 @(posedge clk);
		$stop;															
	end
	
endmodule
