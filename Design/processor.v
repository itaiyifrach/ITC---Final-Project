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

<------------------------ PARAMETERS ------------------------>
- DATA_WIDTH	- data width (32 or 64 bits)

-------------------------------------------------------------
*/

module processor(clk, rst_n, vld, last_data, mode, proc_val, data_in, data_out); 
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
  
  // set local variables
  wire [DATA_WIDTH-1:0]			brightness_out;
  wire [DATA_WIDTH-1:0]			threshold_out;
  wire 							data_out_rdy;

  // init the threshold processor
  threshold_processor #(DATA_WIDTH) t (
    .clk			(clk),
    .rst_n			(rst_n),
    .vld			(threshold_vld),
    .last_data		(last_data),
    .mode			(mode),
    .proc_val		(proc_val),
    .data_in		(data_in),
    .data_out		(threshold_out),
    .data_out_rdy	(data_out_rdy)
  );
  
  // init the brightness processor
  brightness_processor #(DATA_WIDTH) b (
    .clk			(clk),
    .rst_n			(rst_n),
    .vld			(brightness_vld),
    .mode			(mode),
    .proc_val		(proc_val),
    .data_in		(data_in),
    .data_out		(brightness_out),
    .data_out_rdy	(data_out_rdy)
  );
  

  // sending valid to the desired processor
  assign threshold_vld = (vld & !mode[1] & mode[0]) ? 1 : 0;	// if mode = 2'b01
  assign brightness_vld = (vld & mode[1] & !mode[0]) ? 1 : 0;	// if mode = 2'b10
  
  // outputing the data from the desired processor
  assign data_out = mode[1] ? brightness_out : threshold_out;

endmodule : processor