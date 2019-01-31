`include "env.sv"
`include "slave_sequence.sv"
`include "master_sequence.sv"


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
    slave_sequence 		slv0_seq;
    slave_sequence 		slv1_seq;
    master_sequence 	mstr0_seq;
    
    phase.raise_objection(this);
    
    slv0_seq = slave_sequence::type_id::create("slv0_seq");
    slv1_seq = slave_sequence::type_id::create("slv1_seq");
    mstr0_seq = master_sequence::type_id::create("mstr0_seq");
    
    // starting slave0 sequence
    if (!slv0_seq.randomize())
      `uvm_error("", "seq randomize error")
    slv0_seq.start(env_h.active_agent_h.slv0_seq);
    
    // starting slave1 sequence
    if (!slv1_seq.randomize())
      `uvm_error("", "seq randomize error")
    slv1_seq.start(env_h.active_agent_h.slv1_seq);
    
    // starting master0 sequence
    if (!mstr0_seq.randomize())
      `uvm_error("", "seq randomize error")
    mstr0_seq.start(env_h.active_agent_h.mstr0_seq);
    
    #1000 phase.drop_objection(this);
  endtask
  
endclass