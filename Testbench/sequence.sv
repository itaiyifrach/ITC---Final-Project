class sequence extends uvm_sequence#(my_transaction);
  
  `uvm_object_utils(sequence)
  
  
  function new(string name="");
    super.new(name);
  endfunction
  

  task body;
    my_transaction req;
    repeat(1)
    begin
      req = my_transaction::type_id::create("req");
      start_item(req);
      if(!req.randomize())
        `uvm_error("", "req randomize failed")
      finish_item(req);
    end
  endtask
  
  
endclass