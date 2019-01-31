class master_transaction extends uvm_sequence_item;
  
  `uvm_object_utils(master_transaction)
  
  rand logic ready;
  
  function new(string name="");
    super.new(name);
  endfunction : new
  
  function void print();
    $display("/n---- Master 0 ----");
    $display("ready = %0b", ready);
  endfunction : print
  
endclass