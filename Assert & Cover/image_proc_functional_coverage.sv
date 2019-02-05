class image_proc_functional_coverage extends uvm_subscriber #(actual_trans);
 
`uvm_component_utils(image_proc_functional_coverage)

/* 	uvm_analysis_export#(full_transaction) coverage_actual;
	uvm_analysis_export#(full_transaction) coverage_expected;
    
	full_transaction 		expected_trans;
	full_transaction 		actual_trans;
	 */
	covergroup Scens_From_A_Memory @(posedge clk);;
		
		SLVs:  coverpoint whos_grt;
		
		SIZEs: coverpoint file_size {
			bins file_sizes = {56,59, 62, 65, [66:100], 101:10000};}
			
		DATAs: coverpoint data_proc {
			bins Zeroz = {'h0};
			bins Ones  = {8'hFF};
			bins NeGs  = {[8'b10000000 : 8'b11111111:]};
			bins POSs  = {[8'b00000000:8'b01111111]};
			}
			
		cross SLVs, SIZEs, DATAs;
		
	endgroup
	
	function new();
		super.new(name, parent);
		Scens_From_A_Memory = new();
	endfunction
 
/* function void write(T t);
  Scens_From_A_Memory.sample();
endfunction: write */
 
endclass

