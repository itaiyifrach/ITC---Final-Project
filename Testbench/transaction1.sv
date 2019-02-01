`include "image.sv"

class my_transaction extends uvm_sequence_item;
  
  `uvm_object_utils(my_transaction)
   
  // slave 0
  rand logic [1:0] 					slv0_mode;
  rand logic						slv0_data_valid;
  rand logic [`COLOR_SIZE-1:0] 		slv0_proc_val;
  rand logic 						slv0_rdy;
  rand logic						slv0_data_valid_stop;
  rand int							slv0_data_valid_stop_for;
  image 							slv0_image;
  
  // slave 1
  rand logic [1:0] 					slv1_mode;
  rand logic 						slv1_data_valid;
  rand logic [`COLOR_SIZE-1:0] 		slv1_proc_val;
  rand logic 						slv1_rdy;
  rand logic						slv1_data_valid_stop;
  rand int							slv1_data_valid_stop_for;
  image 							slv1_image;
  
  // master
  rand logic 						mstr0_ready;
  rand logic						mstr0_ready_stop;
  rand int							mstr0_ready_stop_for;
  
  
  constraint stops_con {
    slv0_data_valid_stop_for  	inside {[1:10]};
    slv1_data_valid_stop_for 	inside {[1:10]};
    mstr0_ready_stop_for		inside {[1:10]};
  }
  
  function new(string name="");
    super.new(name);
    
    // generating the images
    slv0_image = image::create(`DATA_WIDTH);
    slv1_image = image::create(`DATA_WIDTH);
    
  endfunction : new
  
  function void print(string name);
	$display(" ---- $s ----", 			name);
    
    $display("\n ---- Slave 0 ----");
    $display("slv0_mode = %0b", 		slv0_mode);
    $display("slv0_data_valid = %0b", 	slv0_data_valid);
    $display("slv0_proc_val = %0b", 	slv0_proc_val);
    $display("slv0_rdy = %0b", 			slv0_rdy);
    $display("slv0_proc_val = %0b", 	slv0_data_valid_stop);
    $display("slv0_rdy = %0b", 			slv0_data_valid_stop_for);
    
    $display("\n ---- Slave 1 ----");
    $display("slv1_mode = %0b", 		slv1_mode);
    $display("slv1_data_valid = %0b", 	slv1_data_valid);
    $display("slv1_proc_val = %0b", 	slv1_proc_val);
    $display("slv1_rdy = %0b", 			slv1_rdy);
    $display("slv1_proc_val = %0b", 	slv1_data_valid_stop);
    $display("slv1_rdy = %0b", 			slv1_data_valid_stop_for);
    
    $display("\n ---- Master 0 ----");
    $display("mstr0_ready = %0b", 			mstr0_ready);
    $display("mstr0_ready_stop = %0b", 		mstr0_ready_stop);
    $display("mstr0_ready_stop_for = %0b", 	mstr0_ready_stop_for);
    
  endfunction : print
  
endclass