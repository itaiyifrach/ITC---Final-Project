class monitor extends uvm_monitor;

  `uvm_component_utils(monitor)
  //uvm_analysis_port#(my_transaction) aport;
  uvm_blocking_put_port #(full_transaction) put_port;
	
  virtual dut_if dut_vi;

  function new(string name, uvm_component parent);
    super.new(name, parent);
    put_port = new("put_port", this);
  endfunction

  function void build_phase(uvm_phase phase);
    //aport = new("aport", this);
    if (!uvm_config_db#(virtual dut_if)::get(this, "", "dut_if_db", dut_vi))
      `uvm_error("", "uvm_config_db::get failed!")
  endfunction
  
  task run_phase(uvm_phase phase);
    forever begin
      full_transaction tx;
      @(posedge dut_vi.clk);
      tx = full_transaction::type_id::create("tx");
      tx.slv0_rdy			= dut_vi.slv0_rdy;
      tx.slv1_rdy			= dut_vi.slv1_rdy;
      tx.mstr0_cmplt 		= dut_vi.mstr0_cmplt;
      tx.mstr0_data 		= dut_vi.mstr0_data;
      tx.mstr0_data_valid 	= dut_vi.mstr0_data_valid;
      put_port.get(tx);
    end
  endtask


endclass