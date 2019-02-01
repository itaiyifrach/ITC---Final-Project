class slave_driver extends uvm_driver#(slave_transaction);
  
  `uvm_component_utils(slave_driver)
  
  virtual dut_if 	dut_vi;
  int 				slave_id;
  
  function new(string name, uvm_component parent);
    super.new(name, parent);
    this.slave_id = (name == "slv0_drv") ? 0 : 1;
  endfunction
  
  
  function void build_phase(uvm_phase phase);
    if (!uvm_config_db#(virtual dut_if)::get(this, "", "dut_if_db", dut_vi))
      `uvm_error("", "uvm_config_db::get failed!")
  endfunction
  
      
  task run_phase(uvm_phase phase);
    logic 	data_ptr[][];					// header and pixels array pointer
    int 	data_idx;						// header and pixels index (which data to drive every clk)
    int 	hdr_size, pxls_size;			// header and pixels array size
    bit 	done_with_hdr, done_with_pxls, granted;
    logic 	[`DATA_WIDTH-1:0]	data_in;
    
    forever begin
      // get next transaction
      seq_item_port.get_next_item(req);
      $display("new trans recieved");
      // set helpful variables
      data_idx			 	= 0;
      done_with_hdr			= 0;
      done_with_pxls		= 0;
      granted				= 0;
      hdr_size 				= $size(req.img.header);
      pxls_size 			= $size(req.img.pixels);
      
		
      //always @(posedge dut_vi.clk) begin
      while (!done_with_pxls) begin
        /*if (done_with_pxls) begin
          disable transaction_driver;
        end*/
        $display("enter while");
        @(posedge dut_vi.clk) begin
        if (slave_id == 1) dut_vi.slv1_mode	= req.mode; else dut_vi.slv0_mode = req.mode;
        if (slave_id == 1) dut_vi.slv1_proc_val	= req.proc_val; else dut_vi.slv0_proc_val = req.proc_val;
        granted = (slave_id == 0 && dut_vi.slv0_rdy) || (slave_id == 1 && dut_vi.slv1_rdy);
          $display("granted = %0b", granted);
        // if granted, then start driving the image
        if (granted) begin
          $display("in granted");
          if (slave_id == 1) dut_vi.slv1_data_valid = 1; else dut_vi.slv0_data_valid = 1;	// set valid up
          data_ptr = done_with_hdr ? req.img.pixels : req.img.header;
          
          // read next image data
          for (int i=0; i<`DATA_WIDTH; i++) begin
            data_in[i] = data_ptr[data_idx][`DATA_WIDTH-i-1];
          end
          
          // now drive it and increment data_idx
          if (slave_id == 1) dut_vi.slv1_data = data_in; else dut_vi.slv1_data = data_in;
          data_idx++;
          
          // checker if done to drive the header and pixels
          if (!done_with_hdr && data_idx == hdr_size) begin
            $display("in done with header");
            done_with_hdr 	= 1;
            data_idx 		= 0;
          end
          if (done_with_hdr && data_idx == pxls_size) begin
            $display("in done with pixels");
          	done_with_pxls 	= 1;
            data_idx 		= 0;
          end
        end
        end
      end	// end of always block
      
      seq_item_port.item_done();
      $display("trans done");
    end
  endtask
  
  
endclass