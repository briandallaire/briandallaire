// Erik Michel & Brian Dallaire
// 5/23/2021
// EE 371
// Lab #5, Digital Signal Processing

// noise_gen takes 1-bit signals clk, en, and rst and returns
// a 24 bit signal out. This module is used to add a high-pitched
// noise to the output of the FPGA audio.

module noise_gen (clk, en, rst, out);
	input logic clk, en, rst;
	output logic signed [23:0] out;
	
	logic feedback;
	logic [3:0] LFSR;
	assign feedback = LFSR[3] ~^ LFSR[2];
	
	always_ff @(posedge clk) begin
		if (rst) LFSR <= 4'b0;
		else LFSR <= {LFSR[2:0], feedback};
	end
	
	always_ff @(posedge clk) begin
		if (rst) out <= 24'b0;
		else if (en) out <= {{5{LFSR[3]}}, LFSR[2:0], 16'b0};
	end

endmodule

// noise_gen_testbench is used to test the output of 
// the noise_gen module. 

module noise_gen_testbench();
  logic clk, en, rst;
  logic signed [23:0] out;

  noise_gen dut (.*);

  initial begin
    clk <= 0;
    forever #10 clk <= ~clk;
  end

  initial begin
    en <= 0; rst <= 1;
    repeat (3) @(posedge clk)
    rst <= 0;
    repeat (3) @(posedge clk)
    en <= 1;
    repeat (30) begin
      @(posedge clk);
      $display("%d",out);
    end
    $stop();
  end
endmodule
