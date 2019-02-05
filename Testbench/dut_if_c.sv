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
  
  	covergroup Scens_From_A_Memory @(posedge clk);
		
		SLVs:  coverpoint whos_grt;
		
		SIZEs: coverpoint file_size {
			bins file_sizes = {56,59, 62, 65, [66:100], 101:10000};}
			
		DATAs: coverpoint data_proc {
			bins Zeroz = {'h0};
			bins Ones  = {8'hFF};
			bins NeGs  = {[8'b10000000 : 8'b11111111:]};
			bins POSs  = {[8'b00000000:8'b01111111]};
			}
			
		cross SLVs, SIZEs, DATAs;
		
	endgroup

initial 
	begin
		Scens_From_A_Memory = new();
	end
		Scens_From_A_Memory[i].sample();

end	
	
endinterface