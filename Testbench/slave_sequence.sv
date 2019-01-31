class slave_sequence extends uvm_sequence#(slave_transaction);
  
  `uvm_object_utils(slave_sequence)
  
  
  function new(string name="");
    super.new(name);
  endfunction
  

  task body;
    slave_transaction req;
    repeat(2)
    begin
      req = slave_transaction::type_id::create("req");
      start_item(req);
      if(!req.randomize())
        `uvm_error("", "req randomize failed")
      finish_item(req);
    end
  endtask
  
  
endclass