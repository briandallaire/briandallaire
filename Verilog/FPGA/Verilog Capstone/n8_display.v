// Brian Dellaire, Erik Michel
// EE 371
// Lab 6, Design Project

// n8_display takes 1-bit input clk, right, left, up, down, select, a, b, startblk,
// tpblks, gameover, complete and 6-bit reg signals HEX0-5. The purpose of this module
// is to indicate the occurance of in-game (in-maze) events on the HEX displays. As an
// example, if a player dies in a lava-block the HEX displays will spell "dead". If a
// player is not within a special block like a lava block or a teleportation block, the
// HEX displays will spell out any input given by the player such as "UP" when the player
// presses the up arrow on the controller.

module n8_display (
    input clk,
    input right, left, up, down, select, start, a, b, startblk, tpblks, gameover, complete,
    output reg[6:0] HEX0, 
    output reg[6:0] HEX1,
    output reg[6:0] HEX2,
    output reg[6:0] HEX3,
    output reg[6:0] HEX4,
    output reg[6:0] HEX5);
	
	 parameter TWO = 7'b0100100;
	 parameter A   = 7'b0001000;	 
	 parameter C   = 7'b1000110;
	 parameter D   = 7'b0100001;
	 parameter E   = 7'b0000110;
	 parameter L   = 7'b1000111;
	 parameter P   = 7'b0001100;
	 parameter R   = 7'b0101111;
	 parameter S   = 7'b0010010;
	 parameter T   = 7'b0000111;
	 
    always @(posedge clk) begin
        // Left hex (up/down)
        if (up == 1 && down != 1 && right != 1 && left != 1 && startblk != 1 && tpblks != 1 && gameover != 1 && complete != 1) begin
            // UP
            HEX1 = 7'b1000001;
            HEX0 = 7'b0001100;
        end else if (up != 1 && down == 1 && right != 1 && left != 1 && startblk != 1 && tpblks != 1 && gameover != 1 && complete != 1) begin
            // DO
            HEX1 = 7'b0100001;
            HEX0 = 7'b0100011;
        end else if (up != 1 && down != 1 && right != 1 && left == 1 && startblk != 1 && tpblks != 1 && gameover != 1 && complete != 1) begin
            // LE
            HEX1 = 7'b1000111;
            HEX0 = 7'b0000110;
        end else if (up != 1 && down != 1 && right == 1 && left != 1 && startblk != 1 && tpblks != 1 && gameover != 1 && complete != 1) begin
            // RI
            HEX1 = 7'b1001110;
            HEX0 = 7'b1001111;
        end else if (b == 1 && a != 1 && up != 1 && down != 1 && right != 1 && left != 1 && startblk != 1 && tpblks != 1 && gameover != 1 && complete != 1) begin
            // B
            HEX0 = 7'b0000011;
        end else if (a == 1 && b != 1 && up != 1 && down != 1 && right != 1 && left != 1 && startblk != 1 && tpblks != 1 && gameover != 1 && complete != 1) begin
            // A
            HEX0 = 7'b0001000;
        end else if (startblk == 1 && up != 1 && down != 1 && right != 1 && left != 1 && a != 1 && b != 1) begin
				HEX4 = S;
				HEX3 = T;
				HEX2 = A;
				HEX1 = R;
				HEX0 = T;
		  end else if (tpblks == 1 && startblk != 1 && up != 1 && down != 1 && right != 1 && left != 1 && a != 1 && b != 1) begin
				HEX5 = A;
				HEX3 = TWO;
				HEX1 = T;
				HEX0 = P;
		  end else if(gameover == 1 && complete != 1 && up != 1 && down != 1 && right != 1 && left != 1 && a != 1 && b != 1) begin
				HEX3 = D;
				HEX2 = E;
				HEX1 = A;
				HEX0 = D;
		  end else if(complete == 1 && up != 1 && down != 1 && right != 1 && left != 1 && a != 1 && b != 1) begin
				HEX4 = C;
				HEX3 = L;
				HEX2 = E;
				HEX1 = A;
				HEX0 = R;
		  end else begin 
				HEX5 = 7'b1111111;
				HEX4 = 7'b1111111;
				HEX3 = 7'b1111111;
				HEX2 = 7'b1111111;
				HEX1 = 7'b1111111;
				HEX0 = 7'b1111111;
		  end

    end
    
endmodule 

// n8_display_testbench tests the functionality of the n8_display module
// above by testing that the proper inputs/conditions output the 
// appropriate items on HEX displays 1-5.

`timescale 1 ps / 1 ps
module n8_display_testbench();

   reg clk;
   reg right, left, up, down, select, start, a, b, startblk, tpblks, gameover, complete;
   wire [6:0] HEX0; 
	wire [6:0] HEX1;
   wire [6:0] HEX2;
   wire [6:0] HEX3;
   wire [6:0] HEX4;
   wire [6:0] HEX5;

	n8_display dut (.clk(clk), .right(right), .left(left), .up(up), .down(down), .select(select), .start(start), .a(a), .b(b), .startblk(startblk), .tpblks(tpblks),
						 .gameover(gameover), .complete(complete), .HEX0(HEX0), .HEX1(HEX1), .HEX2(HEX2), .HEX3(HEX3), .HEX4(HEX4), .HEX5(HEX5));
	
   parameter CLOCK_PERIOD=100;
   initial begin
	   clk <= 0;
	forever #(CLOCK_PERIOD/2) clk <= ~clk; // Forever toggle the clock
   end
	
	initial begin
		up <= 0; down <= 0; left <= 0; right <= 0; a <= 0; b <= 0; select <= 0; start <= 0; startblk <= 0; tpblks <= 0; gameover <= 0; complete <= 0; @(posedge clk);
		up <= 1; down <= 0; left <= 0; right <= 0; a <= 0; b <= 0; select <= 0; start <= 0; startblk <= 0; tpblks <= 0; gameover <= 0; complete <= 0; @(posedge clk);
		up <= 0; down <= 1; left <= 0; right <= 0; a <= 0; b <= 0; select <= 0; start <= 0; startblk <= 0; tpblks <= 0; gameover <= 0; complete <= 0; @(posedge clk);
		up <= 0; down <= 0; left <= 1; right <= 0; a <= 0; b <= 0; select <= 0; start <= 0; startblk <= 0; tpblks <= 0; gameover <= 0; complete <= 0; @(posedge clk);
		up <= 0; down <= 0; left <= 0; right <= 1; a <= 0; b <= 0; select <= 0; start <= 0; startblk <= 0; tpblks <= 0; gameover <= 0; complete <= 0; @(posedge clk);
		up <= 0; down <= 0; left <= 0; right <= 0; a <= 1; b <= 0; select <= 0; start <= 0; startblk <= 0; tpblks <= 0; gameover <= 0; complete <= 0; @(posedge clk);
		up <= 0; down <= 0; left <= 0; right <= 0; a <= 0; b <= 1; select <= 0; start <= 0; startblk <= 0; tpblks <= 0; gameover <= 0; complete <= 0; @(posedge clk);
		up <= 0; down <= 0; left <= 0; right <= 0; a <= 0; b <= 0; select <= 1; start <= 0; startblk <= 0; tpblks <= 0; gameover <= 0; complete <= 0; @(posedge clk);
		up <= 0; down <= 0; left <= 0; right <= 0; a <= 0; b <= 0; select <= 0; start <= 1; startblk <= 0; tpblks <= 0; gameover <= 0; complete <= 0; @(posedge clk);
		up <= 0; down <= 0; left <= 0; right <= 0; a <= 0; b <= 0; select <= 0; start <= 0; startblk <= 1; tpblks <= 0; gameover <= 0; complete <= 0; @(posedge clk);
		up <= 0; down <= 0; left <= 0; right <= 0; a <= 0; b <= 0; select <= 0; start <= 0; startblk <= 0; tpblks <= 1; gameover <= 0; complete <= 0; @(posedge clk);
		up <= 0; down <= 0; left <= 0; right <= 0; a <= 0; b <= 0; select <= 0; start <= 0; startblk <= 0; tpblks <= 0; gameover <= 1; complete <= 0; @(posedge clk);
		up <= 0; down <= 0; left <= 0; right <= 0; a <= 0; b <= 0; select <= 0; start <= 0; startblk <= 0; tpblks <= 0; gameover <= 0; complete <= 1; @(posedge clk);
		up <= 0; down <= 0; left <= 0; right <= 0; a <= 0; b <= 0; select <= 0; start <= 0; startblk <= 0; tpblks <= 0; gameover <= 0; complete <= 0; @(posedge clk);
	$stop;
	end
endmodule 