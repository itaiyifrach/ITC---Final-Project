`include "sequencer.sv"
`include "driver.sv"
`include "monitor.sv"


class active_agent extends uvm_agent;
  
  `uvm_component_utils(active_agent)
  //uvm_analysis_port#(my_transaction) aport;
  
  sequencer seq_h;
  driver drv_h;
  monitor monitor_h;
  
  
  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction
  
  
  function void build_phase(uvm_phase phase);
	//aport = new("aport", this);
    seq_h = sequencer::type_id::create("seq_h", this);
    drv_h = driver::type_id::create("drv_h", this);
	monitor_h = monitor_h::type_id::create("monitor_h", this);
  endfunction
  
  
  function void connect_phase(uvm_phase phase);
    drv_h.seq_item_port.connect(seq_h.seq_item_export);	// connect sequencer to driver
	//my_monitor_h.aport.connect(aport);							// connect monitor to port (for scoreboard use)
  endfunction
  
  
endclass