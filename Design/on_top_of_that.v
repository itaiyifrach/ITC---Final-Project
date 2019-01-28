`include "FiFo.v"
`include "scheduler.v"

module bmp_arbiterBFF
	(
//////////Scheduler///////////
	
		/////universe/////
		clk,
		rst_n,
		
		/////slaves/////
		slv0_mode,
		slv0_data_valid,
		slv0_data,
		slv0_data_proc,
		slv0_ready,
		
		slv1_mode,
		slv1_data_valid, 
		slv1_data,
		slv1_data_proc,
		slv1_ready,
		
	/////processor//////////////
		data_to_processor,		
		data_from_processor,
		vld_pr,
		scheduler_2_proc_vld,
		mode,
		data_proc,
		done,

	/////master/////
		mstr0_ready,
		data_to_master,
		mstr0_data_valid,
		mstr0_cmplt,
		);

////////////////I/O////////////////

	input clk;
	input rst_n;

////Slaves Shit/////
	input [1:0] 				slv0_mode;
	input 						slv0_data_valid;
	input [DATA_BUS_SIZE - 1:0] slv0_data;
	input [7:0] 				slv0_data_proc;
	output 						slv0_ready;
	
	input [1:0]					slv1_mode;
	input 						slv1_data_valid;
	input [DATA_BUS_SIZE - 1:0] slv1_data;
	input [7:0] 				slv1_data_proc;
	output 						slv1_ready;

/////Processor interface/////////
	input [DATA_BUS_SIZE - 1:0] data_from_processor; //Data comming back from the processor
	input 						vld_pr; 	 //Points that data from the processor is valid
//	input   					rdy_pr; //

	output reg [DATA_BUS_SIZE - 1:0] data_to_processor;
	output reg [1:0] 				 mode;
	output reg [7:0] 				 data_proc;
	output reg 						 done;	//Points that Arbiter completed transfer data
	
	
	///////////////////TBD//////////////////
	output reg 				 	     scheduler_2_proc_vld; //Points that data from the schedualer to the processor is valid
	///////////////////TBD//////////////////
	
/////Master's/////
	input 								mstr0_ready;
	
	output [DATA_BUS_SIZE - 1:0] 		data_to_master;	
	output [1:0]						mstr0_data_valid;
	output reg							mstr0_cmplt;	
	
//////////////Wires/////////////////////////////////////

	/////Scheduler-FiFo Connections//////
	wire [DATA_BUS_SIZE - 1:0] 	data_sch_FiFo;
	wire [DATA_BUS_SIZE - 1:0] 	data_FiFo_sch;
	wire 						rd_sch_FiFo;
	wire 						wr_sch_FiFo;
	wire 						empty_FiFo_sch;
	wire 						full_FiFo_sch;

///////////////////Instances Of Modulim//////////////////////////////

////////Get The scheduler Instance/////////////	
	scheduler kind_of_scheduler
	(
		/////universe/////
		.clk(clk),
		.rst_n(rst_n),
		
		/////slaves/////
		.slv0_mode(slv0_mode),
		.slv0_data_valid(slv0_data_valid),
		.slv0_data(slv0_data),
		.slv0_data_proc(slv0_data_proc),
		.slv0_ready(slv0_ready),
		
		.slv1_mode(slv1_mode),
		.slv1_data_valid(slv1_data_valid),
		.slv1_data(slv1_data),
		.slv1_data_proc(slv1_data_proc),
		.slv1_ready(slv1_ready),

		/////processor/////
		.data_to_processor(data_to_processor),		
		.data_from_processor(data_from_processor),
		.vld_pr(vld_pr),
		.scheduler_2_proc_vld(scheduler_2_proc_vld),
		.mode(mode),
		.data_proc(data_proc),
		.done(done),	
		//no_of_last_padded_bytes,

		/////master/////
		.mstr0_ready(mstr0_ready),
		.data_to_master(data_to_master),
		.mstr0_data_valid(mstr0_data_valid),
		.mstr0_cmplt(mstr0_cmplt),
		
		/////Fifo/////
		.fifo_rd(rd_sch_FiFo),
		.fifo_wr(wr_sch_FiFo),
		.data_to_fifo(data_sch_FiFo),
		.data_from_fifo(data_FiFo_sch),
		.empty(empty_FiFo_sch),
		.full(full_FiFo_sch)
	);
	////////Get The FiFo Instance/////////////	
	FiFo fDUT 
	(
		.clk(clk), 
		.rst(rst_n), 
		.rd(rd_sch_FiFo), 
		.wr(wr_sch_FiFo), 
		.data_in(data_sch_FiFo), 
		.data_out(data_FiFo_sch), 
		.full(full_FiFo_sch), 
		.empt(empty_FiFo_sch)
	);
	
endmodule