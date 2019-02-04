`include "scoreboard_pkt.sv"

class scoreboard extends uvm_scoreboard;
  
  `uvm_component_utils(scoreboard)
  
  uvm_analysis_export#(full_transaction) scb_export_actual;
  uvm_analysis_export#(full_transaction) scb_export_expected;
  uvm_tlm_analysis_fifo#(full_transaction) actual_fifo;
  uvm_tlm_analysis_fifo#(full_transaction) expected_fifo;
  
  
  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction
  
  
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    scb_export_actual = new("scb_export_actual", this);
    scb_export_expected = new("scb_export_expected", this);
	actual_fifo = new("actual_fifo", this);
	expected_fifo = new("expected_fifo", this);
  endfunction
  
  
  function void connect_phase(uvm_phase phase);
    scb_export_actual.connect(actual_fifo.analysis_export);
    scb_export_expected.connect(expected_fifo.analysis_export);
    
  endfunction
  
  
  virtual task run_phase(uvm_phase phase);
    
    full_transaction 		expected_trans;
    full_transaction 		actual_trans;
    
    logic [1:0]				whos_granted = 2'b10;	// this assign just to indicate if a grant were given
    logic [1:0]				mode;
    logic [`PIXEL_SIZE-1:0]	proc_val;
    logic [`DATA_WIDTH-1:0]	data_in;
    logic					data_vld;
    int 					counter;
    logic [31:0] 			file_size;
    int 					bytes_per_bus = `DATA_WIDTH / `COLOR_SIZE;
    
    forever begin
      // reset values
      whos_granted 	= 2'b10;
      mode			= 0;
      proc_val		= 0;
      data_in		= 0;
      data_vld		= 0;
      counter		= 0;
      file_size		= 0;
      
      while (whos_granted == 2'b10) begin
        expected_fifo.get(expected_trans);
        actual_fifo.get(actual_trans);
        // check which slave supposed to be granted
        if (expected_trans.mstr0_ready && whos_granted == 2'b10) begin
          if (expected_trans.slv0_mode == 2'b01 || expected_trans.slv0_mode == 2'b10) begin
              whos_granted = 2'b00;
          end
          else if (expected_trans.slv1_mode == 2'b01 || expected_trans.slv1_mode == 2'b10) begin
              whos_granted = 2'b01;
          end
          else whos_granted = 2'b10;
      	end
      end	// end of while
      
      mode 		= whos_granted[0] ? expected_trans.slv1_mode : expected_trans.slv0_mode;
      proc_val 	= whos_granted[0] ? expected_trans.slv1_proc_val : expected_trans.slv0_proc_val;
      
      // if the mode is brightness (delay should be 1 clk)
      if (mode == 2'b10) begin
        // wait for first data_vld
        //expected_fifo.get(expected_trans);
        //actual_fifo.get(actual_trans);
        data_vld = whos_granted[0] ? expected_trans.slv1_data_valid : expected_trans.slv0_data_valid;
        while (!data_vld) begin
          expected_fifo.get(expected_trans);
          actual_fifo.get(actual_trans);
          data_vld = whos_granted[0] ? expected_trans.slv1_data_valid : expected_trans.slv0_data_valid;
        end
        
        actual_fifo.get(actual_trans); // this is for delay
        actual_fifo.get(actual_trans); // this is for delay
        actual_fifo.get(actual_trans); // this is for delay
        
        // wait for filesize
        while (counter < 2) begin
          expected_fifo.get(expected_trans);
          actual_fifo.get(actual_trans);
          data_vld = whos_granted[0] ? expected_trans.slv1_data_valid : expected_trans.slv0_data_valid;
          if (data_vld) begin
            data_in = whos_granted[0] ? expected_trans.slv1_data : expected_trans.slv0_data;
            if (counter == 0) file_size[31:16] 	= data_in[15:0];
            if (counter == 1) file_size[15:0] 	= data_in[31:16];
            
            // need to check - master data is valid, correct grant and correct header
            if (whos_granted[0] == actual_trans.mstr0_data_valid[1]) begin
              `uvm_info("grant", $sformatf("\t\tDATA #%0d: <OK>\tExpected = %0b, Actual = %0b", counter, whos_granted[0], actual_trans.mstr0_data_valid[1]), UVM_LOW);
            end else begin
              `uvm_info("grant", $sformatf("\t\tDATA #%0d: <FAIL>\tExpected = %0b, Actual = %0b", counter, whos_granted[0], actual_trans.mstr0_data_valid[1]), UVM_LOW);
            end
            if (data_in == actual_trans.mstr0_data) begin
              `uvm_info("data", $sformatf("\t\tDATA #%0d: <OK>\tExpected = %0h, Actual = %0h", counter, data_in, actual_trans.mstr0_data), UVM_LOW);
            end else begin
              `uvm_info("data", $sformatf("\t\tDATA #%0d: <FAIL>\tExpected = %0h, Actual = %0h", counter, data_in, actual_trans.mstr0_data), UVM_LOW);
            end
            if (actual_trans.mstr0_data_valid[0]) begin
              `uvm_info("mstr0_data_valid", $sformatf("\tDATA #%0d: <OK>\tExpected = 1, Actual = %0b", counter, actual_trans.mstr0_data_valid[0]), UVM_LOW);
            end else begin
              `uvm_info("mstr0_data_valid", $sformatf("\tDATA #%0d: <FAIL>\tExpected = 1, Actual = %0b", counter, actual_trans.mstr0_data_valid[0]), UVM_LOW);
            end
            
            counter++;
          end		// end of if vld
        end			// end of while
        
        // here we got the filesize
        //$display("FILESIZE = %0h", file_size);
        counter = 2*(bytes_per_bus) - 1;		// we already read 8 bytes
        while (counter < file_size) begin
          expected_fifo.get(expected_trans);
          actual_fifo.get(actual_trans);
          data_vld = whos_granted[0] ? expected_trans.slv1_data_valid : expected_trans.slv0_data_valid;
          if (data_vld) begin
            data_in = whos_granted[0] ? expected_trans.slv1_data : expected_trans.slv0_data;
  
            // need to check - master data is valid, correct grant and correct data
            if (whos_granted[0] == actual_trans.mstr0_data_valid[1]) begin
              `uvm_info("grant", $sformatf("\t\tDATA #%0d: <OK>\tExpected = %0b, Actual = %0b", counter/bytes_per_bus, whos_granted[0], actual_trans.mstr0_data_valid[1]), UVM_LOW);
            end else begin
              `uvm_info("grant", $sformatf("\t\tDATA #%0d: <FAIL>\tExpected = %0b, Actual = %0b", counter/bytes_per_bus, whos_granted[0], actual_trans.mstr0_data_valid[1]), UVM_LOW);
            end
            
            if (actual_trans.mstr0_data_valid[0]) begin
              `uvm_info("mstr0_data_valid", $sformatf("\tDATA #%0d: <OK>\tExpected = 1, Actual = %0b", counter/bytes_per_bus, actual_trans.mstr0_data_valid[0]), UVM_LOW);
            end else begin
              `uvm_info("mstr0_data_valid", $sformatf("\tDATA #%0d: <FAIL>\tExpected = 1, Actual = %0b", counter/bytes_per_bus, actual_trans.mstr0_data_valid[0]), UVM_LOW);
            end
            
            
            if (counter >= 56) begin				// if its the pixels, calulate brightness
              data_in = calc_brightness(data_in, proc_val);
            end
            if (data_in == actual_trans.mstr0_data) begin
              `uvm_info("data", $sformatf("\t\tDATA #%0d: <OK>\tExpected = %0h, Actual = %0h", counter/bytes_per_bus, data_in, actual_trans.mstr0_data), UVM_LOW);
            end else begin
              `uvm_info("data", $sformatf("\t\tDATA #%0d: <FAIL>\tExpected = %0h, Actual = %0h", counter/bytes_per_bus, data_in, actual_trans.mstr0_data), UVM_LOW);
            end
            
            counter += bytes_per_bus;
          end		// end of if vld
          else begin
            // HERE CHECK IF NO VLD
          end

        end			// end of while
        // compare master complete...
        if (actual_trans.mstr0_cmplt) begin
          `uvm_info("mstr0_cmplt", $sformatf("\tDATA #%0d: <OK>\tExpected = 1, Actual = %0b", (counter-bytes_per_bus)/bytes_per_bus, actual_trans.mstr0_cmplt), UVM_LOW);
        end
        else begin
          `uvm_info("mstr0_cmplt", $sformatf("\tDATA #%0d: <FAIL>\tExpected = 1, Actual = %0b", (counter-bytes_per_bus)/bytes_per_bus, actual_trans.mstr0_cmplt), UVM_LOW);
        end
        
        
        $display("DONE");
        
        
      end		// end of brightness
      
      // if the mode is threshold
      if (mode == 2'b01) begin
        
        
      end
      
    end		// end of forever
    
  endtask
  
  function logic[`DATA_WIDTH-1:0] calc_brightness(logic[`DATA_WIDTH-1:0] data_in, logic[7:0] proc_val);
    
    logic[`DATA_WIDTH-1:0] 	brightness_array;
    logic[`COLOR_SIZE:0]	brightness_val;
    
    for(int i=0 ; i < `DATA_WIDTH/`COLOR_SIZE ; i++) begin
        brightness_val = data_in[i*`COLOR_SIZE+:`COLOR_SIZE] + proc_val;
        brightness_array[i*`COLOR_SIZE+:`COLOR_SIZE] = brightness_val[`COLOR_SIZE-1:0];

        // if the new color value is negative, then assign 0
        if ($signed(proc_val) < 0 && $signed(data_in[i*`COLOR_SIZE+:`COLOR_SIZE] + proc_val) < 0) begin
          brightness_array[i*`COLOR_SIZE+:`COLOR_SIZE] = {(`COLOR_SIZE){1'b0}};
        end
        // if the new color value is positive, then assign 255
        if (brightness_val[`COLOR_SIZE] == 1) begin
          brightness_array[i*`COLOR_SIZE+:`COLOR_SIZE] = {(`COLOR_SIZE){1'b1}};
        end
      end
    return brightness_array;
    
  endfunction : calc_brightness
  
  /*
  virtual task run_phase(uvm_phase phase);
    
    forever begin
      expected_fifo.get(expected_trans);
      
      // check which slave supposed to be granted
      if (expected_trans.mstr0_ready && whos_granted = 2'b10) begin
        if (expected_trans.slv0_mode == 2'b01 || expected_trans.slv0_mode == 2'b10) begin
        	whos_granted = 2'b00;
        end
        else if (expected_trans.slv1_mode == 2'b01 || expected_trans.slv1_mode == 2'b10) begin
        	whos_granted = 2'b01;
        end
        else whos_granted = 2'b10;
      end
    
    
    //void'(push_expected());
    //void'(push_actual());
  endtask
  
  
  virtual function void push_expected();
    full_transaction 		expected_trans;
    logic [1:0]				whos_granted = 2'b10;	// this assign just to indicate if a grant were given
 	logic [1:0]				mode;
  	logic [`PIXEL_SIZE-1:0]	proc_val;
    logic					data_vld;
    int 					counter;
    int 					file_size;
    bit						init_pkt;
    
    forever begin
      expected_fifo.get(expected_trans);
      
      // check which slave supposed to be granted
      if (expected_trans.mstr0_ready && whos_granted = 2'b10) begin
        if (expected_trans.slv0_mode == 2'b01 || expected_trans.slv0_mode == 2'b10) begin
        	whos_granted = 2'b00;
        end
        else if (expected_trans.slv1_mode == 2'b01 || expected_trans.slv1_mode == 2'b10) begin
        	whos_granted = 2'b01;
        end
        else whos_granted = 2'b10;
      end
      
      // if someone supposed to be granted, then wait for the data and save it
      if (whos_granted != 2'b10) begin
        if (init_pkt) begin
          mode = whos_granted[0] ? expected_trans.slv1_mode : expected_trans.slv0_mode;
          proc_val = whos_granted[0] ? expected_trans.slv1_proc_val : expected_trans.slv0_proc_val; 
          // instansing the scoreboard_pkt object
          scoreboard_pkt expected_pkt = scoreboard_pkt::create(whos_granted[0], mode, proc_val);
        end
        else begin
          // wait for first data_valid
          expected_fifo.get(expected_trans);
          data_vld = whos_granted[0] ? expected_trans.slv1_data_vld : expected_trans.slv0_data_vld;
          while (!data_vld) begin
            expected_fifo.get(expected_trans);
          	data_vld = whos_granted[0] ? expected_trans.slv1_data_vld : expected_trans.slv0_data_vld;
          end
          // after first vld, start saving the header and wait for file size
          for (int i=0; i<`DATA_WIDTH; i++) begin
            data_ptr[counter][] = data_ptr[data_idx][`DATA_WIDTH-i-1];
          end
        end
      end
        
      end
      
    end
    
    
  endfunction : push_expected
  	
  
  virtual function void push_actual();
    full_transaction actual_trans;
    
    forever begin
      
    end
    
  endfunction : push_actual
    
  */

endclass