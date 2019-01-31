class full_transaction extends uvm_sequence_item;
  
  `uvm_object_utils(full_transaction)
  
  logic [1:0] 					slv0_mode;
  logic							slv0_data_valid;
  logic [`COLOR_SIZE-1:0] 		slv0_proc_val;
  logic [DATA_WIDTH-1:0] 		slv0_data;
  logic 						slv0_rdy;
  logic [1:0] 					slv1_mode;
  logic 						slv1_data_valid;
  logic [`COLOR_SIZE-1:0] 		slv1_proc_val;
  logic [DATA_WIDTH-1:0] 		slv1_data;
  logic 						slv1_rdy;
  logic 						mstr0_cmplt;
  logic 						mstr0_ready;
  logic [DATA_WIDTH-1:0] 		mstr0_data;
  logic [1:0] 					mstr0_data_valid;
  
  
  constraint stops_con {
    slv0_data_valid_stop_for  	inside {[1:10]};
    slv1_data_valid_stop_for 	inside {[1:10]};
    mstr0_ready_stop_for		inside {[1:10]};
  }
  
  function new(string name="");
    super.new(name);
  endfunction : new
  
  function void print();    
    $display("\n ---- Slave 0 ----");
    $display("slv0_mode = %0b", 		slv0_mode);
    $display("slv0_data_valid = %0b", 	slv0_data_valid);
    $display("slv0_proc_val = %0h", 	slv0_proc_val);
    $display("slv0_data = %0h", 		slv0_data);
    $display("slv0_rdy = %0b", 			slv0_rdy);

    
    $display("\n ---- Slave 1 ----");
    $display("slv1_mode = %0b", 		slv1_mode);
    $display("slv1_data_valid = %0b", 	slv1_data_valid);
    $display("slv1_proc_val = %0h", 	slv1_proc_val);
    $display("slv0_data = %0h", 		slv1_data);
    $display("slv1_rdy = %0b", 			slv1_rdy);

    
    $display("\n ---- Master 0 ----");
    $display("mstr0_cmplt = %0b", 			mstr0_cmplt);
    $display("mstr0_ready = %0b", 			mstr0_ready);
    $display("mstr0_data = %0b", 			mstr0_data);
    $display("mstr0_data_valid = %0b", 		mstr0_data_valid);
  endfunction : print
  
endclass