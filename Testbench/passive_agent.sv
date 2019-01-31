`include "exp_monitor.sv"


class passive_agent extends uvm_agent;
  
  `uvm_component_utils(passive_agent)
  //uvm_analysis_port#(my_transaction) aport;
  
  exp_monitor exp_monitor_h;
  
  
  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction
  
  
  function void build_phase(uvm_phase phase);
	//aport = new("aport", this);
	exp_monitor_h = exp_monitor::type_id::create("exp_monitor_h", this);
  endfunction
  
  
  function void connect_phase(uvm_phase phase);
	//my_exp_monitor.aport.connect(aport);			// connect monitor to port (for scoreboard use)
  endfunction
  
  
endclass