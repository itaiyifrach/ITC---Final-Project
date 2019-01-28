`include "image_processing_acclerator.v"

module test;
  
  parameter DATA_WIDTH = 32;
  
  logic 					clk;
  logic 					rst_n;
  logic [1:0] 				slv0_mode;
  logic 					slv0_data_valid;
  logic [`COLOR_SIZE-1:0] 	slv0_proc_val;
  logic [DATA_WIDTH-1:0] 	slv0_data;
  logic 					slv0_ready;
  logic [1:0] 				slv1_mode;
  logic 					slv1_data_valid;
  logic [`COLOR_SIZE-1:0] 	slv1_proc_val;
  logic [DATA_WIDTH-1:0] 	slv1_data;
  logic 					slv1_ready;
  logic 					mstr0_cmplt;
  logic 					mstr0_ready;
  logic [DATA_WIDTH-1:0] 	mstr0_data;
  logic [1:0] 				mstr0_data_valid;
  
  initial begin
    $dumpfile("processor.vcd");
      $dumpvars;
  end
  
  // clock generator
  always begin
   	#5 clk = ~clk;
  end
  
  initial begin
    rst_n = 1;
    #7 rst_n = ~rst_n;
    #7 rst_n = ~rst_n;
  end
  
  // create the DUT
  image_processing_acclerator #(.DATA_WIDTH(DATA_WIDTH)) img_proc_acc (
    .clk				(clk),
    .rst_n				(rst_n),
    .slv0_mode			(slv0_mode),
    .slv0_data_valid	(slv0_data_valid),
    .slv0_proc_val		(slv0_proc_val),
    .slv0_data			(slv0_data),
    .slv0_ready			(slv0_ready),
    .slv1_mode			(slv1_mode),
    .slv1_data_valid	(slv1_data_valid),
    .slv1_proc_val		(slv1_proc_val),
    .slv1_data			(slv1_data),
    .slv1_ready			(slv1_ready),
    .mstr0_cmplt		(mstr0_cmplt),
    .mstr0_ready		(mstr0_ready),
    .mstr0_data			(mstr0_data),
    .mstr0_data_valid	(mstr0_data_valid)
     );
  
  initial begin
    #150 $finish;
  end
  
  
endmodule