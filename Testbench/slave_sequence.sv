class slave_sequence extends uvm_sequence#(slave_transaction);
  
  `uvm_object_utils(slave_sequence)
  
  
  function new(string name="");
    super.new(name);
  endfunction
  

  task body;
    slave_transaction req;
    $display("done");
    repeat(1)
    begin
      $display("done");
      req = slave_transaction::type_id::create("req");
      start_item(req);
      if(!req.randomize())
        `uvm_error("", "req randomize failed")
      $display("done");
      req.print(0);
      finish_item(req);
      $display("done");
    end
  endtask
  
  
endclass