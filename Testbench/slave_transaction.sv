`include "image.sv"

class slave_transaction extends uvm_sequence_item;
  
  `uvm_object_utils(slave_transaction)
  
  rand logic [1:0] 					mode;
  rand logic [`COLOR_SIZE-1:0] 		proc_val;
  rand logic 						rdy;
  rand logic						data_valid_stop;
  rand int							data_valid_stop_for;
  image 							image;
  
  
  
  constraint stops_con {
    data_valid_stop_for inside {[1:10]};
  }
  
  function new(string name="");
    super.new(name);
    
    // generating the images
    image = image::create(`DATA_WIDTH);
    
  endfunction : new
  
  function void print(int id);
    $display("\n ---- Slave %0d ----",	id);
    $display("mode = %0b", 		mode);
    $display("proc_val = %0b", 	proc_val);
    $display("rdy = %0b", 			rdy);
    $display("proc_val = %0b", 	data_valid_stop);
    $display("rdy = %0b", 			data_valid_stop_for);
    
    
  endfunction : print
  
endclass