`include "slave_sequencer.sv"
`include "master_sequencer.sv"
`include "slave_driver.sv"
`include "master_driver.sv"
`include "monitor.sv"


class active_agent extends uvm_agent;
  
  `uvm_component_utils(active_agent)
  //uvm_analysis_port#(my_transaction) aport;
  
  // slave 0
  slave_sequencer 	slv0_seq;
  slave_driver 		slv0_drv;
  
  // slave 1
  slave_sequencer 	slv1_seq;
  slave_driver 		slv1_drv;
  
  // master
  master_sequencer 	msrt0_seq;
  master_driver	 	mstr0_drv;
  
  // monitor
  monitor 			monitor_h;
  
  
  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction
  
  
  function void build_phase(uvm_phase phase);
	//aport = new("aport", this);
    slv0_seq = sequencer::type_id::create("slv0_seq", this);
    slv0_drv = driver::type_id::create("slv0_drv", this);
    slv1_seq = sequencer::type_id::create("slv0_seq", this);
    slv1_drv = driver::type_id::create("slv0_drv", this);
    msrt0_seq = sequencer::type_id::create("msrt0_seq", this);
    mstr0_drv = driver::type_id::create("mstr0_drv", this);
	monitor_h = monitor_h::type_id::create("monitor_h", this);
  endfunction
  
  
  function void connect_phase(uvm_phase phase);
    slv0_drv.seq_item_port.connect(slv0_seq.seq_item_export);	// connect slave0 seq to it's driver
    slv1_drv.seq_item_port.connect(slv1_seq.seq_item_export);	// connect slave1 seq to it's driver
    mstr0_drv.seq_item_port.connect(msrt0_seq.seq_item_export);	// connect master seq to it's driver
	//my_monitor_h.aport.connect(aport);							// connect monitor to port (for scoreboard use)
  endfunction
  
  
endclass