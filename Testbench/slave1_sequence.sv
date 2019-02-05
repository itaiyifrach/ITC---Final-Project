class slave1_sequence extends uvm_sequence#(slave_transaction);
  
  `uvm_object_utils(slave1_sequence)
  
  
  function new(string name="");
    super.new(name);
  endfunction
  

  task body;
    slave_transaction req;
    //$display("done");
    repeat(10)
    begin
      //$display("done");
      req = slave_transaction::type_id::create("req");
      start_item(req);
      if(!req.randomize())
        `uvm_error("", "req randomize failed")
        
      req.mode = 2'b10;
      //$display("done");
      //req.print(slave_id);
      finish_item(req);
      //$display("done");
    end
    
    //  end transaction (no request)
    req = slave_transaction::type_id::create("req");
    start_item(req);
    if(!req.randomize())
        `uvm_error("", "req randomize failed")
    req.mode 		= 0;
    req.proc_val 	= 0;
    finish_item(req);
  endtask
  
  
endclass