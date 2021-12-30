// Brian Dallaire
// 12/3/2021
// EE 469
// Lab #4

// flagRegisters 1-bit inputs clk, reset, setflags, zero, negative, overflow, 
// and carry_out and the 1-bit outputs zeroReg, negativeReg, overflReg, and
// carry_oReg. The purpose of this module is to represent the flag registers
// in the CPU. When the control signal setflags is true, it will update what is
// in the flag registers, or in essence, set flags.

`timescale 1ps/1ps

module flagRegisters(clk, reset, setflags, zero, negative, overflow,
							carry_out,  zeroReg, negativeReg, overflReg, carry_oReg);

	input logic clk, reset;
	input logic setflags, zero, negative, overflow, carry_out;

	output logic zeroReg, negativeReg, overflReg, carry_oReg;
	
	logic zeroflag, negflag, overflag, carry_oflag;



	
	//set flags when setflags is true
	mux_2_1 flagz (.select(setflags), .load({zero, zeroReg}), .data(zeroflag));
	mux_2_1 flagn (.select(setflags), .load({negative, negativeReg}), .data(negflag));
	mux_2_1 flago (.select(setflags), .load({overflow, overflReg}), .data(overflag));
	mux_2_1 flagc (.select(setflags), .load({carry_out, carry_oReg}), .data(carry_oflag));
	
	// flag registers to maintain flag values
	D_FF dflagz (.q(zeroReg), .d(zeroflag), .reset, .clk);
	D_FF dflagn (.q(negativeReg), .d(negflag), .reset, .clk);
	D_FF dflago (.q(overflReg), .d(overflag), .reset, .clk);
	D_FF dflagc (.q(carry_oReg), .d(carry_oflag), .reset, .clk);
	

endmodule 

// flagRegisters_testbench test for the relevant behaviors. In this testbench,
// I tested multiple flags and saw the effects it had on the registers when
// setflags was true or false.

module flagRegisters_testbench();

	logic clk, reset;
	logic setflags, zero, negative, overflow, carry_out;
	logic zeroReg, negativeReg, overflReg, carry_oReg;
	
	flagRegisters dut (.clk, .reset, .setflags, .zero, .negative, .overflow,
							.carry_out, .zeroReg, .negativeReg, .overflReg, .carry_oReg);
	
	parameter CLOCK_PERIOD = 100;
	
	initial begin 
		clk <= 0;
		forever #(CLOCK_PERIOD/2) clk <= ~clk;
	end
	
	initial begin 

	reset <= 1; setflags <= 0; setflags <= 0; zero <= 0; negative <= 0; overflow <= 0; carry_out <= 0; @(posedge clk);
	reset <= 0; setflags <= 1; setflags <= 0; zero <= 0; negative <= 0; overflow <= 0; carry_out <= 0; @(posedge clk);
	reset <= 0; setflags <= 0; setflags <= 1; zero <= 0; negative <= 1; overflow <= 1; carry_out <= 0; @(posedge clk);
	reset <= 0; setflags <= 1; setflags <= 1; zero <= 0; negative <= 1; overflow <= 1; carry_out <= 0; @(posedge clk);
	reset <= 0; setflags <= 1; setflags <= 0; zero <= 0; negative <= 0; overflow <= 0; carry_out <= 0; @(posedge clk);

	$stop;
	
	end
endmodule 