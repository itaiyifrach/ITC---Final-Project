`include "processor.v"
`include "on_top_of_that.v"

`define COLOR_SIZE 8
`define PIXEL_SIZE 24

module image_processing_acclerator (
	clk,
	rst_n,
	slv0_mode,
	slv0_data_valid,
	slv0_proc_val,
	slv0_data,
	slv0_ready,
	slv1_mode,
	slv1_data_valid,
	slv1_proc_val,
	slv1_data,
	slv1_ready,
	mstr0_cmplt,
	mstr0_ready,
	mstr0_data,
	mstr0_data_valid
	);
	
  parameter DATA_WIDTH = 32;
  //parameter DATA_BUS_SIZE = 32;
  // set inputs and outputs
  input wire						clk;
  input wire						rst_n;
  
  // slave 0
  input wire [1:0]					slv0_mode;
  input wire						slv0_data_valid;
  input wire [`COLOR_SIZE-1:0] 		slv0_proc_val;
  input wire [DATA_WIDTH-1:0] 		slv0_data;
  output wire 				 		slv0_ready;
  
  // slave 1
  input wire [1:0]					slv1_mode;
  input wire						slv1_data_valid;
  input wire [`COLOR_SIZE-1:0] 		slv1_proc_val;
  input wire [DATA_WIDTH-1:0] 		slv1_data;
  output wire 				 		slv1_ready;
  
  // master
  output wire						mstr0_cmplt;
  input wire						mstr0_ready;
  output wire [DATA_WIDTH-1:0] 		mstr0_data;
  output wire [1:0]					mstr0_data_valid;
  
  // internal variables
  wire [DATA_WIDTH-1:0]				data_to_processor;
  wire 								data_vld_to_processor;
  wire 								done_to_processor;
  wire [DATA_WIDTH-1:0]				data_to_arbiter;
  wire								data_vld_to_arbiter;
  wire [1:0]						mode_to_processor;
  wire [`COLOR_SIZE-1:0]			data_proc_to_processor;
  wire								processor_done;			// might delete this
  
  
  
  
  // create the arbiter
  bmp_arbiterBFF #(.DATA_BUS_SIZE(DATA_WIDTH)) arbiter (
	.clk					(clk),
	.rst_n					(rst_n),
	
	// slave 0
	.slv0_mode				(slv0_mode),
	.slv0_data_valid		(slv0_data_valid),
	.slv0_data				(slv0_data),
	.slv0_data_proc			(slv0_proc_val),
    .slv0_ready				(slv0_ready),
    
	// slave 1
	.slv1_mode				(slv1_mode),
	.slv1_data_valid		(slv1_data_valid), 
	.slv1_data				(slv1_data),
    .slv1_data_proc			(slv1_proc_val),
    .slv1_ready				(slv1_ready),
	
	// master 
	.mstr0_ready			(mstr0_ready),
	.data_to_master			(mstr0_data),
	.mstr0_data_valid		(mstr0_data_valid),
    .mstr0_cmplt			(mstr0_cmplt),
	
	// processor
	.data_to_processor		(data_to_processor),
	.data_from_processor	(data_to_arbiter),
	.vld_pr					(data_vld_to_arbiter),
	.scheduler_2_proc_vld	(data_vld_to_processor),
	.mode					(mode_to_processor),
	.data_proc				(data_proc_to_processor),
	.done					(done_to_processor)	
	);

	
  // create the processor
  processor #(.DATA_WIDTH(DATA_WIDTH)) processor (
	.clk			(clk),
    .rst_n			(rst_n),
    .vld			(data_vld_to_processor),
    .last_data		(done_to_processor),
    .mode			(mode_to_processor),
    .proc_val		(data_proc_to_processor),
    .data_in		(data_to_processor),
    .data_out		(data_to_arbiter),
    .data_out_vld	(data_vld_to_arbiter),
    .done			(processor_done)			// might delete this
	);
	
	
endmodule : image_processing_acclerator