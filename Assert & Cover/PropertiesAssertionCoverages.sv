/* 1. If any of the slv  valid is on than its mode should be 01 or 10
 */
property vld0_mode;
 @(posedge clk)
 $rose(slv0_data_valid) |-> $onehot0(slv0_mode);
endproperty 
assert (vld0_mode);
cover  (vld0_mode);

property vld1_mode;
 @(posedge clk)
 $rose(slv1_data_valid) |-> $onehot0(slv1_mode);
endproperty 
assert (vld1_mode);
cover  (vld1_mode);

//if (slv0_req && slv0_data_vld), than it will get grant some time in the future
property 	granting;
	@(posedge clk)
		$rose($onehot0(mode) && slvx_valid) [*1:$] ##[0:$] $rose(whos_grt==00 && mstr_ready);
endproperty 
assert (granting);
cover  (granting);

//Not fairness - if slv 0 granted, and its valid high than next grant should be gnt[0]
property 	not_fairness;
	@(posedge clk)
		slv0_req ##[0:$] (slv0_grt) throughout slv1_grt[->2];
endproperty 
assert (not_fairness);
cover  (not_fairness);


//if slvx granted in TH mode, master out == slv_data (from 3rd clk till the end of header)	
property slv0_mstr_th_hdr_timming;
	$rose(mst0_start_outputting && slv0_th_mode) |-> ($sampled(data_to_master) == $past(slv0_data, TH_DEAD_TIME)) throughout !(start_processing);
endproperty 
assert (slv0_mstr_th_hdr_timming);
cover  (slv0_mstr_th_hdr_timming); 

property slv1__mstr_th_hdr_timming;
	$rose(mst0_start_outputting && slv1_th_mode) |-> ($sampled(data_to_master) == $past(slv1_data, TH_DEAD_TIME)) throughout !(start_processing);
endproperty 
assert (slv1__mstr_th_hdr_timming);
cover  (slv1__mstr_th_hdr_timming);
 

//if slvx granted in B mode, master out == slv_data (from 1st clk till the end of header)
property slv0_mstr_b_hdr_timming;
	$rose(mst0_start_outputting && slv0_b_mode) |-> ($sampled(data_to_master) == $past(slv0_data, B_DEAD_TIME)) throughout !(start_processing);
endproperty 
assert (slv0_mstr_b_hdr_timming);
cover  (slv0_mstr_b_hdr_timming);
 

property slv1_mstr_b_hdr_timming;
	$rose(mst0_start_outputting && slv1_b_mode) |-> ($sampled(data_to_master) == $past(slv1_data, B_DEAD_TIME)) throughout !(start_processing);
endproperty 
assert (slv1_mstr_b_hdr_timming);
cover  (slv1_mstr_b_hdr_timming); 

//if granted in TH mode, master out == data_from_processor (from 3rd clk afret processing begins till the end of file processing)	
property processor_mstr_th_hdr_timming;
	$rose(mst0_start_outputting && reg_mode[0] && vld_pr) |-> ($sampled(data_to_master) == $past(data_from_processor, TH_DEAD_TIME)) throughout !(start_processing);
endproperty 
assert (processor_mstr_th_hdr_timming);
cover  (processor_mstr_th_hdr_timming); 

//if granted in b mode, master out == data_from_processor (from 3rd clk afret processing begins till the end of file processing)	
property processor_mstr_th_hdr_timming;
	$rose(mst0_start_outputting && reg_mode[1] && vld_pr) |-> ($sampled(data_to_master) == $past(data_from_processor, B_DEAD_TIME)) throughout !(start_processing);
endproperty 
assert (processor_mstr_th_hdr_timming)
cover  (processor_mstr_th_hdr_timming) 

//sticky mode from gnt till end of file transfer
property sticky0_mode;
	$rose(slv0_grt | slv1_grt) |=> $stable(mode);
endproperty  
assert (sticky0_mode);
cover  (sticky0_mode);

//if data is valid, is known
property sch_proc_known_vld;
	scheduler_2_proc_vld |=> !$isunknown(data_to_processor);
endproperty 
assert (sch_proc_known_vld);
cover  (sch_proc_known_vld);

property proc_known_vld;
	vld_pr |=> !$isunknown(data_from_processor);
endproperty 
assert (proc_known_vld);
cover  (proc_known_vld);

property mst_known_vld;
	mstr0_data_valid |=> !$isunknown(data_to_master);
endproperty 
assert (mst_known_vld);
cover  (mst_known_vld);

//reset @ times
property reset_after_slv0_st;
	$rose(slv0_st) |=> !rst_n;
endproperty
assert (reset_after_slv0_st);
cover  (reset_after_slv0_st);
	
property reset_after_slv1_st;
	$rose(slv1_st) |=> !rst_n;
endproperty
assert (reset_after_slv1_st);
cover  (reset_after_slv1_st);

property reset_at_proc_st;
	$rose(start_processing) |=> !rst_n;
endproperty
assert (reset_at_proc_st);
cover  (reset_at_proc_st);

property reset_at_proc_fn;
	$rose(finish_processing) |=> !rst_n;
endproperty
assert (reset_at_proc_fn);
cover  (reset_at_proc_fn);

//pausing at times

////////////////Cover Groupim//////////////////////////////

// covergroup FILE_SIZE;
	// coverpoint file_size 
		// bins file_sizes = {56,59, 62, 65, 66:100, 101:10000};
// endgroup

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

//can make a sequence cover to signal to a covergroup that its on, than, track those. We define those sequence cover in the INTERFACE, with a variable that will signal the cover class when the sequence been trigered, than it can be recorded oin a covergroup.

/* 
covergroup JIM;
	coverpoint data_proc
		bins Zeroz = {'h0};
		bins Ones  = {8'hFF};
		bins NeGs  = {8'b1111111:8'b01111111};
endgroup */
