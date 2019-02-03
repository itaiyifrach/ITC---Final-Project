

module scheduler
	(
		/////universe/////
		clk,
		rst_n,
		reset,
		
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
		
		/////processor/////
		data_to_processor,		
		data_from_processor,
		vld_pr,
		scheduler_2_proc_vld,
		//no_of_last_padded_bytes,
		mode,
		data_proc,
		done,
		
		/////Fifo/////
		fifo_rd,
		fifo_wr,
		data_to_fifo,
		data_from_fifo,
		empty,
		full,
		
		/////master/////
		mstr0_ready,
		data_to_master,
		mstr0_data_valid,
		mstr0_cmplt,
	);
	
	parameter DEBUG 		= 1;
	parameter DATA_BUS_SIZE = 32;
	parameter DEAD_TIME = 3;
	
/////Universe Shit/////
	input clk;
	input rst_n;
	output reg reset;
	
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


	output reg [DATA_BUS_SIZE - 1:0] data_to_processor;
	output reg [1:0] 				 mode;
	output reg [7:0] 				 data_proc;
	output reg 						 done;	//Points that Arbiter completed transfer data
	
	
	///////////////////TBD//////////////////
	output reg 				 	     scheduler_2_proc_vld; //Points that data from the schedualer to the processor is valid
	///////////////////TBD//////////////////
	
	
	
/////FiFo Shit////////
	input wire 							empty;
	input reg  [DATA_BUS_SIZE - 1:0] 	data_from_fifo;
	input								full;
	
	output [DATA_BUS_SIZE - 1:0] 		data_to_fifo;
	output reg 							fifo_rd;
	output reg 							fifo_wr;


/////Master's/////
	input 								mstr0_ready;
	
	output [DATA_BUS_SIZE - 1:0] 		data_to_master;	
	output reg [1:0]					mstr0_data_valid;
	output reg							mstr0_cmplt;



////////////////// Regs /////////////
	
	//data_start_pos = Offset where the pixel array (bitmap data) can be found, should be 56 bytes
	//p_biBitCount = No of bit per pixel, should be 24
	reg  [31:0] 					file_size;
    reg  [3:0] 						counter 		= 0;
	reg  [5:0]						bytes_per_data 	= DATA_BUS_SIZE>>3; //How many bytes are in data bus
	reg  [25:0]						BMPcount 		= 0; 				//Count bytes being transfered
	reg  [1:0] 						whos_grt; 							//Which slave got the grant (whos_grt = 10 for neither)
	reg  [7:0] 						BMP [55:0]; 						//Register to hold the header
	reg 							mstr_ready;
	reg	 [1:0]						reg_mode;							//register to save the mode for when input finished
	
	wire [DATA_BUS_SIZE - 1:0]		data;
	reg 							rst = 1;
	reg								the_end;
	
	////////Who's the chosen slave /////////
	//assign whos_grt 		= (slv0_data_valid && (slv0_mode != 2'b00) && (slv0_mode != 2'b11))? 2'b00 :(slv1_data_valid && ((slv1_mode != 2'b00) && (slv1_mode != 2'b11 )))? 2'b01 : 2'b10;
	
	assign whos_grt 		= ((slv0_mode == 2'b01) || (slv0_mode == 2'b10))? 2'b00 : ((slv1_mode == 2'b01) || (slv1_mode == 2'b10))?  2'b01 : 2'b10;
	
	///////Give it to the processor/////////
	assign mode 				= (whos_grt == 2'b00)? slv0_mode : (whos_grt == 2'b01)? slv1_mode : 2'b00;
	assign data_proc 			= (whos_grt == 2'b00)? slv0_data_proc : (whos_grt == 2'b01)? slv1_data_proc : 8'b0;
	assign data					= (whos_grt == 2'b00)? slv0_data : (whos_grt == 2'b01)? slv1_data : 2'b00;
	assign data_to_processor	= data;
	assign scheduler_2_proc_vld = ((mstr_ready) && (rst_n) && (BMPcount >= 56) && !(done))? 'b1 : 'b0;
	assign done 				= (BMPcount >= file_size)? 'b1 : 'b0; 
	
	////////Get The FiFo Wired/////////////
	assign data_to_fifo = ((BMPcount >= 0) && (BMPcount < 56))? data : (vld_pr)? data_from_processor : data;
	
	// FiFo's wr is on from first input msg till end of last msg of the processor (on TH mode)
	//assign fifo_wr 			= (((reset) && (mode == 2'b01) && (BMPcount < 56) && (mode != 2'b10) )||(vld_pr))? 'b1:'b0;
	assign fifo_wr 			= ((reset) && (mstr_ready) && (BMPcount < 56)||(vld_pr))? 'b1 : 'b0;
	
	// FiFo's rd is on from #DEAD_TIME after end of headers (on TH mode) till FiFo empty
	// FiFo's rd is on from the beggining of headers (on b mode) till Pix input	
	assign fifo_rd 			= ((mstr_ready) && (reset) && (reg_mode == 2'b01) && (BMPcount > 3 * bytes_per_data) && (!empty))? 'b1: ((mstr_ready) && (reset) && (reg_mode == 2'b10) && (BMPcount < 56))? 'b1: 'b0;
	
	/////To The Master/////
	assign data_to_master	= (reg_mode[1] && (BMPcount > 56))? data_from_processor : data_from_fifo;
	assign mstr0_data_valid = ((mstr_ready) && (reset) && (reg_mode == 2'b01) && (BMPcount > 3 * bytes_per_data) && (fifo_rd))? {whos_grt[0], 1'b1} : ((mstr_ready) && (reset) && (reg_mode == 2'b10) && (vld_pr))? {whos_grt[0], 1'b1} : 'b0;
	
	/////// Whats going on in your head???//////
	//assign file_size 		= {BMP[2], BMP[3], BMP[4], BMP[5]};
	assign file_size 		= {BMP[5], BMP[4], BMP[3], BMP[2]};
	assign mstr_ready 		= (slv0_data_valid || slv1_data_valid)? mstr0_ready:'b0; //if nothing is valid, dont do it	
	
	assign slv0_ready = (whos_grt==2'b00);
	assign slv1_ready = (whos_grt==2'b01);

	assign reset = (mstr0_cmplt)? rst : rst_n;

	assign the_end = ((reg_mode == 2'b10) && (BMPcount >= file_size))? 1'b1 :  ((reg_mode == 2'b01) && (BMPcount >= file_size + DEAD_TIME))? 1'b1 : 1'b0;
	assign mstr0_cmplt = the_end;
	assign reg_mode = (!done)? mode : reg_mode;

	
		always @(clk, reset)
			begin
				if (!reset)
					begin
						BMPcount				<= 0;
						rst						<= 1;
					end
			end
///////////////////////////////////////////////////////////////////////////////	
	
  always @(posedge clk, reset)
	begin
	////////reseting first!/////////
		if (mstr_ready && reset)
			begin
				if (BMPcount < 56) 
					begin
                      for (counter = 0; counter < bytes_per_data; counter++)
							begin
							  #0;
                              BMP[BMPcount] 		= data [(3-counter) * 8 +: 8];
							  BMPcount 			= BMPcount + 1;
							end	
					end
				if ((BMPcount >= 56) && (BMPcount < file_size + DEAD_TIME))						 
					begin 
						BMPcount 				= BMPcount + bytes_per_data; 
					end
					
						if (mstr0_cmplt) 
							begin
								$display ( "master completed!! @ %t ", $time);
								rst = 0;
							end
			end
	end

endmodule
	