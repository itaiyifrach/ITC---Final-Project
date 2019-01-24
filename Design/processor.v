`include brightness_processor.v
`include threshold_processor.v

`define COLOR_SIZE 8
`define PIXEL_SIZE 24

/*
-------------------------------------------------------------
------------------------ PROCESSOR --------------------------
-------------------------------------------------------------
This module calculates threshold and brightness of given
pixels.

<------------------------- INPUTS -------------------------->
- clk			- clock
- rst_n			- reset
- vld			- determine if the data is valid
- last_data		- determine if the data_in is the last data
- mode			- determine which function to calculate:
    0: Nothing				(just passing data_in to data_out atm)
    1: Threshold
    2: Brightness
    3: For future function 	(just passing data_in to data_out atm)
- proc_val		- This is the threshold value or 
                      the added brightness value
- data_in		- incoming data

<------------------------- OUTPUTS -------------------------->
- data_out		- the calculated data
- data_out_vld	- indicates if the data_out is valid
- done			- indicated when finished processing all the data

<------------------------ PARAMETERS ------------------------>
- DATA_WIDTH	- data width (32 or 64 bits)

-------------------------------------------------------------
*/

module processor(clk, rst_n, vld, last_data, mode, proc_val, data_in, data_out, data_out_vld, done); 
  parameter DATA_WIDTH = 32;
  
  // set inputs and outputs
  input wire						clk;
  input wire						rst_n;
  input wire						vld;
  input wire						last_data;
  input wire [1:0] 					mode;
  input wire [`COLOR_SIZE-1:0] 		proc_val;
  input wire [DATA_WIDTH-1:0] 		data_in;
  output reg [DATA_WIDTH-1:0] 		data_out;
  output wire						data_out_vld;
  output wire						done;
  
  // set local variables
  wire [DATA_WIDTH-1:0]			brightness_out;
  wire							brightness_vld_in;
  wire 							brightness_vld_out;
  wire							brightness_done;
  wire [DATA_WIDTH-1:0]			threshold_out;
  wire							threshold_vld_in;
  wire							threshold_vld_out;
  wire							threshold_done;

  // init the threshold processor
  threshold_processor #(DATA_WIDTH) threshold (
    .clk			(clk),
    .rst_n			(rst_n),
    .vld			(threshold_vld_in),
    .last_data		(last_data),
    .mode			(mode),
    .proc_val		(proc_val),
    .data_in		(data_in),
    .data_out		(threshold_out),
    .data_out_vld	(threshold_vld_out),
    .done			(threshold_done)
  );
  
  // init the brightness processor
  brightness_processor #(DATA_WIDTH) brightness (
    .clk			(clk),
    .rst_n			(rst_n),
    .vld			(brightness_vld_in),
    .last_data		(last_data),
    .mode			(mode),
    .proc_val		(proc_val),
    .data_in		(data_in),
    .data_out		(brightness_out),
    .data_out_vld	(brightness_vld_out),
    .done			(brightness_done)
  );
  

  // sending valid to the desired processor
  // IMPORTANT - if mode == 0 or 3, then the processor won't work!
  assign threshold_vld_in = (vld & !mode[1] & mode[0]) ? 1 : 0;	// if mode = 2'b01
  assign brightness_vld_in = (vld & mode[1] & !mode[0]) ? 1 : 0;	// if mode = 2'b10
  
  // set the outputs
  assign data_out = mode[1] ? brightness_out : threshold_out;
  assign done = (threshold_done || brightness_done) ? 1 : 0;
  assign data_out_vld = (threshold_vld_out || brightness_vld_out) ? 1 : 0;
  

endmodule : processor