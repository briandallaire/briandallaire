// Erik Michel & Brian Dallaire
// 5/23/2021
// EE 371
// Lab #5, Digital Signal Processing

// wideDFF takes a 1-bit clk signal, a 1-bit reset signala WIDTH-bit input 'd', 
// and returns a WIDTH-bit signal 'q' on the rising edge of the clk signal. 
// 'q' is whatever value 'd' was right before the rising edge of the clock. 
// when the reset signal is detected, the value of 'q' will become zero
// regardless of the value of 'd'. Also, the value of q will only update
// on the rising edge of the clock if the 'en' signal is ON.
// D_FF_testbench tests that given an input d, the noResetFF
// module will output the proper value for q on the rising edge of
// a clk signal

module wideDFF #(parameter WIDTH = 24) (clk, reset, en, d, q);
    output logic [WIDTH-1:0] q;
    input logic  [WIDTH-1:0] d;
    input logic  reset, clk, en;

    always_ff @(posedge clk) begin
        if (reset)
            q <= 0; //on reset, set to 0
        else if (en)
            q <= d; //otherwise out = d
        end
endmodule 	

// wideDFF_testbench tests that given an input d and en
// tests to see if en is true if the output q will be
// the value going into the DFF
module wideDFF_testbench();
    logic  q;
    logic  d, reset, en, clk;

    wideDFF dut (q, d, reset, en, clk);

    parameter CLOCK_PERIOD=100;
    initial begin
        clk <= 0;
        forever #(CLOCK_PERIOD/2) clk <= ~clk; // Forever toggle the clock
    end

    initial begin

        reset <= 1;                                        @(posedge clk);
        reset <= 0; d <= 0; en <= 0;                @(posedge clk);
                                                            @(posedge clk);

        repeat (5) begin
            d <= 24'b000011110000111100001111;    @(posedge clk);
            d <= 0;                                         @(posedge clk);
        end
        en <= 1;                                            @(posedge clk);
                repeat (5) begin
            d <= 24'b000011110000111100001111;  @(posedge clk);
            d <= 0;                                         @(posedge clk);
        end

        $stop;

    end
endmodule 