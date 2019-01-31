class monitor extends uvm_monitor;

	`uvm_component_utils(monitor)
	//uvm_analysis_port#(my_transaction) aport;
	uvm_blocking_put_port #(my_transaction) put_port;
	
	virtual dut_if dut_vi;
	
	function new(string name, uvm_component parent);
		super.new(name, parent);
		put_port = new(“put_port”, this);
	endfunction
	
	function void build_phase(uvm_phase phase);
		//aport = new("aport", this);
		if (!uvm_config_db#(virtual dut_if)::get(this, "", "dut_if_db", dut_vi))
			`uvm_error("", "uvm_config_db::get failed!")
	endfunction
	
	task run_phase(uvm_phase phase);
		forever begin
			my_transaction tx;
			@(posedge dut_vi.clk);
			tx = my_transaction::type_id::create("tx");
			tx.counter = dut_vi.count;
			my_put_port.get(tx);
		end
	
	endtask


endclass