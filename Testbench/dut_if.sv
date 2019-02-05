interface dut_if;
  
  logic 						clk;
  logic 						rst_n;
  logic [1:0] 					slv0_mode;
  logic							slv0_data_valid;
  logic [`COLOR_SIZE-1:0] 		slv0_proc_val;
  logic [`DATA_WIDTH-1:0] 		slv0_data;
  logic 						slv0_rdy;
  logic [1:0] 					slv1_mode;
  logic 						slv1_data_valid;
  logic [`COLOR_SIZE-1:0] 		slv1_proc_val;
  logic [`DATA_WIDTH-1:0] 		slv1_data;
  logic 						slv1_rdy;
  logic 						mstr0_cmplt;
  logic 						mstr0_ready;
  logic [`DATA_WIDTH-1:0] 		mstr0_data;
  logic [1:0] 					mstr0_data_valid;
	
endinterface