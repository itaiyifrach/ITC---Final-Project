class master_sequence extends uvm_sequence#(master_transaction);
  
  `uvm_object_utils(master_sequence)
  
  
  function new(string name="");
    super.new(name);
  endfunction
  

  task body;
    master_transaction req;
    repeat(1000)
    begin
      req = master_transaction::type_id::create("req");
      start_item(req);
      if(!req.randomize())
        `uvm_error("", "req randomize failed")
      finish_item(req);
    end
  endtask
  
  
endclass