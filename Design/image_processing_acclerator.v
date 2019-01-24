`include processor.v
`include bmp_arbiter.v

`COLOR_SIZE 8

module image_processing_acclerator(
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
  input reg							mstr0_rdy;
  output wire [DATA_WIDTH-1:0] 		mstr0_data;
  output [1:0]						mstr0_data_valid;
  

  // init the arbiter processor
  bmp_arbiter #(DATA_BUS_SIZE = DATA_WIDTH) arbiter (
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