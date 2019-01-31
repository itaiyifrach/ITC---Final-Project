class master_driver extends uvm_driver#(master_transaction);
  
  `uvm_component_utils(master_driver)
  
  virtual dut_if dut_vi;
  
  
  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction
  
  
  function void build_phase(uvm_phase phase);
    if (!uvm_config_db#(virtual dut_if)::get(this, "", "dut_if_db", dut_vi))
      `uvm_error("", "uvm_config_db::get failed!")
  endfunction
  
      
  task run_phase(uvm_phase phase);

    forever begin
      // get next transaction
      seq_item_port.get_next_item(req);
      
      // determine if the slaves supposed to get granted
      slv0_to_be_granted = (req.slv0_mode == 2'b01 || req.slv0_mode == 2'b10) ? 1 : 0;
      slv1_to_be_granted = (req.slv0_mode == 2'b01 || req.slv0_mode == 2'b10) ? 1 : 0;
      master_num_of_cmplts = slv0_to_be_granted + slv1_to_be_granted;
      
      @(posedge dut_vi.clk);
      dut_vi.slv0_mode			= req.slv0_mode;
      //dut_vi.slv0_data_valid;
      dut_vi.slv0_proc_val		= req.slv0_proc_val;
      dut_vi.slv1_mode			= req.slv1_mode;
      //dut_vi.slv0_data_valid;
      dut_vi.slv1_proc_val		= req.slv1_proc_val;
      dut_vi.mstr0_ready		= mstr0_ready;
      
      
      seq_item_port.item_done();
    end
  endtask
  
  
endclass