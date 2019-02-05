`include "env.sv"
`include "slave0_sequence.sv"
`include "slave1_sequence.sv"
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
    slave0_sequence 	slv0_seq;
    slave1_sequence 	slv1_seq;
    master_sequence 	mstr0_seq;
    
    phase.raise_objection(this);
    
    slv0_seq = slave0_sequence::type_id::create("slv0_seq");
    slv1_seq = slave1_sequence::type_id::create("slv1_seq");
    mstr0_seq = master_sequence::type_id::create("mstr0_seq");
    
    
    fork
    // starting master0 sequence
      begin
        if (!mstr0_seq.randomize())
          `uvm_error("", "seq randomize error")
        $display("starting master0 sequence");
        mstr0_seq.start(env_h.active_agent_h.mstr0_seq);
        $display("done master0 sequence");
      end
      begin
        // starting slave0 sequence
        if (!slv0_seq.randomize())
          `uvm_error("", "seq randomize error")
        $display("starting slave0 sequence");
        slv0_seq.start(env_h.active_agent_h.slv0_seq);
        $display("done slave0 sequence");
      end
      
      begin
        // starting slave1 sequence
        if (!slv1_seq.randomize())
          `uvm_error("", "seq randomize error")
        $display("starting slave1 sequence");
        slv1_seq.start(env_h.active_agent_h.slv1_seq);
        $display("done slave1 sequence");
      end
    join
    phase.drop_objection(this);
    /*

    */
    

  endtask
  
endclass