class exp_monitor extends uvm_monitor;
  
  `uvm_component_utils(exp_monitor)
  //uvm_analysis_port#(my_transaction) aport;
  uvm_blocking_put_port #(full_transaction) put_port;
	
  virtual dut_if dut_vi;
	
  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    //aport = new("aport", this);
    if (!uvm_config_db#(virtual dut_if)::get(this, "", "dut_if_db", dut_vi))
      `uvm_error("", "uvm_config_db::get failed!")
  endfunction

  task run_phase(uvm_phase phase);
    forever begin
      my_transaction tx;
      @(posedge dut_vi.clk);
      tx = my_transaction::type_id::create("tx");
      // slave 0
      tx.slv0_mode			= dut_vi.slv0_mode;
      tx.slv0_data_valid	= dut_vi.slv0_data_valid;
      tx.slv0_proc_val		= dut_vi.slv0_proc_val;
      tx.slv0_data 			= dut_vi.slv0_data;
      // slave 1
      tx.slv1_mode			= dut_vi.slv1_mode;
      tx.slv1_data_valid	= dut_vi.slv1_data_valid;
      tx.slv1_proc_val		= dut_vi.slv1_proc_val;
      tx.slv1_data 			= dut_vi.slv1_data;
      // master
      tx.mstr0_ready 		= dut_vi.mstr0_ready;
      my_put_port.get(tx);
    end
  endtask
    

endclass