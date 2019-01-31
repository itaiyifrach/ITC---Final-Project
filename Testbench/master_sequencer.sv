class master_sequencer extends uvm_sequencer#(master_transaction);
  
  `uvm_component_utils(master_sequencer)
  
  
  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction
  
endclass