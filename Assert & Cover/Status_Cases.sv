////////EVENTIM/Status Cases/////////

// request of slv x - $rose($onehot(mode) && slvx_valid)
sequence slv0_req;
	$rose($onehot0(mode) && slv0_valid);
endsequence

sequence slv1_req;
	$rose($onehot0(mode) && slv1_valid);
endsequence

// grant to slv x - not nececerily started
sequence slv0_grt;
	$rose(slv0_ready);
endsequence

sequence slv1_grt;
	$rose(slv1_ready);
endsequence

//slvx started
sequence slv0_st;
	$rose(slv0_ready && slv0_data_valid && mstr0_ready);
endsequence

sequence slv1_st;
	$rose(slv1_ready && slv1_data_valid && mstr0_ready);
endsequence

//start master outputing event - $rose(mstr0_data_valid)
sequence mst0_start_outputting;
	$rose(mstr0_data_valid);
endsequence

// finish master outputing event - $fell(mstr0_data_valid)
sequence mst0_finish_outputting;
	$fell(mstr0_data_valid);
endsequence

//start outputting to the processor - $rose(scheduler_2_proc_vld)
sequence start_processing;
	$rose(scheduler_2_proc_vld)
endsequence

//finish outputting to the processor - $fell(scheduler_2_proc_vld)
sequence finish_processing;
	$fell(scheduler_2_proc_vld)
endsequence

//slvx started in TH mode - $rose(whos_grt==x && mstr_ready && 01)
sequence slv0_th_mode;
	$rose(whos_grt==00 && mstr_ready && slv0_mode == 01 && slv0_data_valid);
endsequence

sequence slv1_th_mode;
	$rose(whos_grt==01 && mstr_ready && slv1_mode == 01  slv1_data_valid);
endsequence

//slvx granted in B mode - $rose(whos_grt==x && mstr_ready && 10)
sequence slv0_b_mode;
	$rose(whos_grt==00 && mstr_ready && slv0_mode == 10&& slv0_data_valid);
endsequence

sequence slv1_b_mode;
	$rose(whos_grt==01 && mstr_ready && slv1_mode == 10&& slv1_data_valid);
endsequence


//slv drop its vld before completion
sequence slv_pause;
	$rose(mstr_ready && !mstr0_ready);
endsequence

//processing TH multiple files continuesly from slvx
sequence slv0_slv0_TH;
	$rose(slv0_th_mode) |-> #[0:$] $rose(not($rose(slv1_th_mode)) && $rose(slv0_th_mode));
endsequence : slv0_mult_TH

sequence slv1_slv1_TH;
	$rose(slv1_th_mode) |-> #[0:$] $rose(not($rose(slv0_th_mode)) && $rose(slv1_th_mode));
endsequence : slv1_mult_TH

//processing b multiple files continuesly from slvx 
sequence slv0_slv0_b;
	$rose(slv0_b_mode) |-> #[0:$] $rose(not($rose(slv1_b_mode)) && $rose(slv0_b_mode));
endsequence : slv0_mult_b

sequence slv1_slv1_b;
	$rose(slv1_b_mode) |-> #[0:$] $rose(not($rose(slv0_b_mode)) && $rose(slv1_b_mode));
endsequence : slv1_slv1_b

//serving slv 0, than slv 1
sequence slv0_than_slv1;
	$rose(slv0_st) |-> #[0:$] $rose(not($rose(slv0_st)) && (slv1_st));
endsequence slv0_than_slv1

//serving slv 1, than slv 0
sequence slv1_than_slv0;
	$rose(slv1_st) |-> #[0:$] $rose(not($rose(slv1_st)) && (slv0_st));
endsequence slv1_than_slv0

//serving slv 0 with TH, than slv 1 with TH
sequence slv0_TH_than_slv1_TH;
	$rose(slv0_th_mode) |-> #[0:$] $rose(not($rose(slv0_st)) && (slv1_th_mode));
endsequence slv0_TH_than_slv1_TH

//serving slv 1 with TH, than slv 0 with TH
sequence slv1_TH_than_slv0_TH;
	$rose(slv1_th_mode) |-> #[0:$] $rose(not($rose(slv1_st)) && (slv0_th_mode));
endsequence slv1_TH_than_slv0_TH

