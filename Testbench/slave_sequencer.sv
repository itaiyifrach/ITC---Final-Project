class slave_sequencer extends uvm_sequencer#(slave_transaction);
  
  `uvm_component_utils(slave_sequencer)
  
  
  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction
  
endclass