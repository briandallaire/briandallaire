// Erik Michel & Brian Dallaire
// 5/23/2021
// EE 371
// Lab #5, Digital Signal Processing

// DE1_SoC takes a 1-bit CLOCK_50 signal, a 1-bit CLOCK2_50 signal
// a 1-bit FPGA_I2C_SDAT signal, 1-bit AUD_DACLRCK, AUD_ADCLRCK, AUD_BCLK
// and AUD_ADCDAT signals, a 4-bit KEY signal for using the KEY buttons on 
// the FPGA board, a 10-bit SW signal for using the switches on the board.
// DE1_SoC returns 6 7-bit HEX0-5 signals that can be used to control the
// HEX displays on the FPGA board, a 10-bit LEDR signal that can be used to
// illuminated LED's on the FPGA board, a 1-bit FPGA_I2C_SCLK signal, a 
// 1-bit AUD_XCK signal, and a 1-bit AUD_DACDAT signal.

// TASK 1: DE1_SoC performs the task of introducing noise to input 
// audio with the help of an instantiated noise_reg module.
// For task 1, only KEY0 needs to be used to introduce noise into
// an input audio source.
//
// Task 2: DE1_SoC calls the simple averaging Finite Impulse Response
// (FIR) filter for both noisy_left and noisy_right variables to reduce
// unwanted noise. Task 2 can be implemented using KEY[1]
//
// Task 3: DE1_SoC calls the variable N sample averaging FIR filter to
// filter both noisy_left and noisy_right even further. Task 3 can be
// implemented using KEY[2]

module DE1_SoC (CLOCK_50, CLOCK2_50, FPGA_I2C_SCLK, FPGA_I2C_SDAT,
	AUD_XCK, AUD_DACLRCK, AUD_ADCLRCK, AUD_BCLK, AUD_ADCDAT, AUD_DACDAT,
	KEY, SW, HEX0, HEX1, HEX2, HEX3, HEX4, HEX5, LEDR);

	input logic CLOCK_50, CLOCK2_50;
	input logic [3:0] KEY;
	input logic [9:0] SW;
	output logic [6:0] HEX0, HEX1, HEX2, HEX3, HEX4, HEX5;
	output logic [9:0] LEDR;
	
	// I2C Audio/Video config interface
	output FPGA_I2C_SCLK;
	inout FPGA_I2C_SDAT;
	// Audio CODEC
	output AUD_XCK;
	input AUD_DACLRCK, AUD_ADCLRCK, AUD_BCLK;
	input AUD_ADCDAT;
	output AUD_DACDAT;
	
	// Local wires
	logic read_ready, write_ready, read, write;
	logic signed [23:0] readdata_left, readdata_right;
	logic signed [23:0] writedata_left, writedata_right;
	logic signed [23:0] task2_left, task2_right, task3_left, task3_right;
	logic signed [23:0] noisy_left, noisy_right;
	logic reset;
	
	logic [23:0] noise;
	
	// noise_gen takes the 1-bit inputs CLOCK_50, read and reset and outputs the 24-bit
	// output noise. The main purpose of this module is to implement unwanted noise into
	// the mp3 file playing on the FPGA board when read is true. 
	noise_gen noise_generator (.clk(CLOCK_50), .en(read), .rst(reset), .out(noise));
	
	assign noisy_left = readdata_left + noise;
	assign noisy_right = readdata_right + noise;
	
	//****************** TASK 2 MODULES ******************//
	
	// FIR filter takes the 1-bit inputs CLOCK_50, reset, and read and the 24-bit input
	// noisy_left and outputs the 24-bit output task2_left. The main purpose of this module
	// is to filter the noise from noisy_left using the FIR filter from Task 2. 
	FIR_filter noise_filterL (.clk(CLOCK_50), .reset, .en(read), .dataIn(noisy_left), .dataOut(task2_left));
	
	// FIR filter takes the 1-bit inputs CLOCK_50, reset, and read and the 24-bit input
	// noisy_right and outputs the 24-bit output task2_right. The main purpose of this module
	// is to filter the noise from noisy_right using the FIR filter from Task 2. 
	FIR_filter noise_filterR (.clk(CLOCK_50), .reset, .en(read), .dataIn(noisy_right), .dataOut(task2_right));
	
	
	//****************** TASK 3 MODULES ******************//
	
	// nSamp_FIR takes the 1-bit inputs CLOCK_50, reset, and read and the 24-bit input
	// noisy_left and outputs the 24-bit output task3_left. The main purpose of this module
	// is to filter the noise from noisy_left using the variable FIR filter from Task 3. In
	// this case it is using a value of N = 16
	nSamp_FIR  nSamp_L		 (.clk(CLOCK_50), .reset, .en(read), .dataIn(noisy_left), .dataOut(task3_left));
	
	// nSamp_FIR takes the 1-bit inputs CLOCK_50, reset, and read and the 24-bit input
	// noisy_right and outputs the 24-bit output task3_right. The main purpose of this module
	// is to filter the noise from noisy_right using the variable FIR filter from Task 3. In
	// this case it is using a value of N = 16
	nSamp_FIR  nSamp_R		 (.clk(CLOCK_50), .reset, .en(read), .dataIn(noisy_right), .dataOut(task3_right));
	
	always_comb begin
		case(KEY[2:0])
			3'b110: begin // KEY0 outputs noise
				writedata_left = noisy_left;
				writedata_right = noisy_right;
			end
			3'b101: begin // KEY1 outputs task2 filtered noise
				writedata_left = task2_left;
				writedata_right = task2_right;
			end
			3'b011: begin // KEY2 outputs task3 filtered noise
				writedata_left = task3_left;
				writedata_right = task3_right;
			end
			default: begin // default output raw data
				writedata_left = readdata_left;
				writedata_right = readdata_right;
			end
		endcase
	end

	assign reset = ~KEY[3];
	assign {HEX0, HEX1, HEX2, HEX3, HEX4, HEX5} = '1;
	assign LEDR = SW;
	
	// only read or write when both are possible
	assign read = read_ready & write_ready;
	assign write = read_ready & write_ready;
	
/////////////////////////////////////////////////////////////////////////////////
// Audio CODEC interface. 
//
// The interface consists of the following wires:
// read_ready, write_ready - CODEC ready for read/write operation 
// readdata_left, readdata_right - left and right channel data from the CODEC
// read - send data from the CODEC (both channels)
// writedata_left, writedata_right - left and right channel data to the CODEC
// write - send data to the CODEC (both channels)
// AUD_* - should connect to top-level entity I/O of the same name.
//         These signals go directly to the Audio CODEC
// I2C_* - should connect to top-level entity I/O of the same name.
//         These signals go directly to the Audio/Video Config module
/////////////////////////////////////////////////////////////////////////////////
	clock_generator my_clock_gen(
		// inputs
		CLOCK2_50,
		1'b0,

		// outputs
		AUD_XCK
	);

	audio_and_video_config cfg(
		// Inputs
		CLOCK_50,
		1'b0,

		// Bidirectionals
		FPGA_I2C_SDAT,
		FPGA_I2C_SCLK
	);

	audio_codec codec(
		// Inputs
		CLOCK_50,
		1'b0,

		read,	write,
		writedata_left, writedata_right,

		AUD_ADCDAT,

		// Bidirectionals
		AUD_BCLK,
		AUD_ADCLRCK,
		AUD_DACLRCK,

		// Outputs
		read_ready, write_ready,
		readdata_left, readdata_right,
		AUD_DACDAT
	);

endmodule


