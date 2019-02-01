class scoreboard extends uvm_scoreboard;
  
  `uvm_component_utils(scoreboard)
  uvm_analysis_imp#(full_transaction, scoreboard) scb_actual;
  uvm_analysis_imp#(full_transaction, scoreboard) scb_expected;
  //uvm_blocking_get_port #(full_transaction) expected_get_port;
  //uvm_blocking_get_port #(full_transaction) actual_get_port;
  
  
  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction
  
  
  function void build_phase(uvm_phase phase);
    scb_actual = new("scb_actual", this);
    scb_expected = new("scb_expected", this);
	//expected_get_port = new("expected_get_port", this);
	//actual_get_port = new("actual_get_port", this);
  endfunction
  
  
  virtual function void write(full_transaction pkt);
    //$display("SCB:: Pkt recived");
    //pkt.print();
  endfunction : write
  
  /*
  virtual task run_phase(uvm_phase phase);
	full_transaction expected_trans;
	full_transaction actual_trans;
	
    
    forever begin
		my_expected_get_port.get(expected_trans);
		my_actual_get_port.get(actual_trans);
		if (trans.load)
			exp_count = expected_trans.data_in;
		else if (expected_trans.enable)
			exp_count = exp_count + 8'h01;
			
			
		if (exp_count == actual_trans.count)
			$display("Result as expected!");
		else 
			$display("Wrong Result!\n\tExpected %0d Actual %0d", exp_count, actual_trans.count);
		
    end
    
  endtask
  */
  
endclass