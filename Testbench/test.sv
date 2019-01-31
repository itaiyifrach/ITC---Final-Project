`include "env.sv"
`include "sequence.sv"

class test extends uvm_test;
  
  `uvm_component_utils(test)
  
  env env_h;
  
  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction
  
  function void build_phase(uvm_phase phase);
    env_h = env::type_id::create("env_h", this);
  endfunction
  
  task run_phase(uvm_phase phase);
    sequence seq;
    phase.raise_objection(this);
    seq = sequence::type_id::create("seq");
    if (!seq.randomize())
      `uvm_error("", "seq randomize error")
    seq.start(env_h.agent_h.seq_h);
    #50 phase.drop_objection(this);
  endtask
  
endclass