`include "active_agent.sv"
`include "passive_agent.sv"
`include "subscriber.sv"

class env extends uvm_env;
  
  `uvm_component_utils(env)
  
  active_agent active_agent_h;
  passive_agent passive_agent_h;
  scoreboard scoreboard_h;

  uvm_tlm_fifo#(my_transaction) expected_fifo;
  uvm_tlm_fifo#(my_transaction) actual_fifo;

  
  function new(string name, uvm_component parent);
    super.new(name, parent);
	expected_fifo = new("expected_fifo", this);
    actual_fifo = new("actual_fifo", this);
  endfunction

  
  function void build_phase(uvm_phase phase);
    active_agent_h = active_agent::type_id::create("active_agent_h", this);
    passive_agent_h = passive_agent::type_id::create("passive_agent_h", this);
	scoreboard_h = scoreboard::type_id::create("scoreboard_h", this);
  endfunction
  
  
  function void connect_phase(uvm_phase phase);
	//my_agent_h.aport.connect(my_scoreboard_h.scb_actual);
	//my_passive_agent_h.aport.connect(my_scoreboard_h.scb_expected);
	active_agent_h.monitor_h.put_port.connect(actual_fifo.put_export);
	passive_agent_h.exp_monitor_h.put_port.connect(expected_fifo.put_export);
	scoreboard_h.actual_get_port.connect(actual_fifo.get_export);
	scoreboard_h.expected_get_port.connect(expected_fifo.get_export);
  endfunction
  
  
endclass