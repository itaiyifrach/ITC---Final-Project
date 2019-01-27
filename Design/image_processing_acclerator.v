`include processor.v
`include bmp_arbiterBFF.v


module image_processing_acclerator (
	clk,
	rst_n,
	slv0_mode,
	slv0_data_valid,
	slv0_proc_val,
	slv0_data,
	slv0_rdy,
	slv1_mode,
	slv1_data_valid,
	slv1_proc_val,
	slv1_data,
	slv1_rdy,
	mstr0_cmplt,
	mstr0_rdy,
	mstr0_data,
	mstr0_data_valid
	);
	
  parameter DATA_WIDTH = 32;
  
  // set inputs and outputs
  input wire						clk;
  input wire						rst_n;
  
  // slave 0
  input wire [1:0]					slv0_mode;
  input wire						slv0_data_valid;
  input wire [`COLOR_SIZE-1:0] 		slv0_proc_val;
  input wire [DATA_WIDTH-1:0] 		slv0_data;
  output reg 				 		slv0_rdy;
  
  // slave 1
  input wire [1:0]					slv1_mode;
  input wire						slv1_data_valid;
  input wire [`COLOR_SIZE-1:0] 		slv1_proc_val;
  input wire [DATA_WIDTH-1:0] 		slv1_data;
  output reg 				 		slv1_rdy;
  
  // master
  output wire						mstr0_cmplt;
  input reg							mstr0_ready;
  output wire [DATA_WIDTH-1:0] 		mstr0_data;
  output [1:0]						mstr0_data_valid;
  
  // internal variables
  wire [DATA_WIDTH-1:0]				data_to_processor;
  wire 								data_vld_to_processor;
  wire 								done_to_processor;
  wire [DATA_WIDTH-1:0]				data_to_arbiter;
  wire								data_vld_to_arbiter;
  
  
  
  
  // create the arbiter
  bmp_arbiterBFF #(DATA_BUS_SIZE = DATA_WIDTH) arbiter (
	.clk				(clk),
	.rst_n				(rst_n),
	.mode				(mode),
	.data_proc			(data_proc),
	
	
	.slv0_mode			(slv0_mode),
	.slv0_data_valid	(slv0_data_valid),
	.slv0_data			(slv0_data),
	.slv0_data_proc		(slv0_data_proc),
	
	.slv1_mode			(slv1_mode),
	.slv1_data_valid	(slv1_data_valid), 
	.slv1_data			(slv1_data),
	.slv1_data_proc		(slv1_data_proc),
	
	.mstr0_ready		(mstr0_ready),
	.mstr0_data_valid	(mstr0_data_valid),
	// complete to master??
	
	.data_out_pr		(data_to_arbiter),
	.vld_pr				(data_vld_to_arbiter),
	
	.data_to_processor	(data_to_processor),
	.data_to_master		(data_to_master),
	.valid				(data_vld_to_processor),
	.done				(done_to_processor)		// is it done to processor (i.e last_data)?
	);

	
  // create the processor
  processor #(DATA_WIDTH = DATA_WIDTH) processor (
	.clk			(clk),
    .rst_n			(rst_n),
    .vld			(valid_to_processor),
    .last_data		(done_to_processor),
    .mode			(mode),
    .proc_val		(proc_val),
    .data_in		(data_to_processor),
    .data_out		(data_to_arbiter),
	.data_out_vld	(data_vld_to_arbiter),
	//.done			()
	);
	
	
endmodule : image_processing_acclerator