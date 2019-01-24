
`timescale 1ns/1ns
`include "FiFo.v"
parameter DEBUG	= 0;

module bmp_arbiterBFF
	(
		clk,
		rst_n,
		slv0_mode,
		slv0_data_valid,
		slv0_data,
		slv0_data_proc,
		slv1_mode,
		slv1_data_valid, 
		slv1_data,
		slv1_data_proc,
		data_out_pr,
		vld_pr,
		mstr0_ready,
		data_to_processor,
		data_to_master,
		mode,
		data_proc,
		mstr0_data_valid,

		valid,
		done
	);
	
	parameter DATA_BUS_SIZE = 32; //Bus data size, can be 32 or 64
	parameter DEAD_TIME 	= 4; //Dead time in Threshold mode
    
	input clk;
    input rst_n;

////Slaves Shit/////
	input [1:0] 				slv0_mode;
	input 						slv0_data_valid;
	input [DATA_BUS_SIZE - 1:0] slv0_data;
	input [7:0] 				slv0_data_proc;
	
	input [1:0]					slv1_mode;
	input 						slv1_data_valid;
	input [DATA_BUS_SIZE - 1:0] slv1_data;
	input [7:0] 				slv1_data_proc;

	input [DATA_BUS_SIZE - 1:0] data_out_pr; //Data comming back from the processor
	input 						vld_pr; 	 //Points that data from the processor is valid
	
	
////Masters Shit/////
	input mstr0_ready;
	
	output reg [DATA_BUS_SIZE - 1:0] data_to_processor;  //Outputed data
	output reg [DATA_BUS_SIZE - 1:0] data_to_master;  //Outputed data

	output reg 						 valid;  // Signals that Outputed data on bus is valid
	output reg 						 done;	//Arbiter complete transfer req
	output reg [1:0] 				 mode;
	output reg [7:0] 				 data_proc;
	output reg [1:0] 				 mstr0_data_valid;
	
	reg 						mstr_ready; //create mstr_ready reg for pausing
////FiFo Shit////////
	reg [DATA_BUS_SIZE - 1:0] 	data_to_fifo;
	reg [DATA_BUS_SIZE - 1:0] 	data_from_fifo;
	reg 						fifo_rd;
	reg 						fifo_wr;
	wire 						full;
	wire 						empty;

	FiFo fDUT 
	(
		.clk(clk), 
		.rst(rst_n), 
		.rd(fifo_rd), 
		.wr(fifo_wr), 
		.data_in(data_to_fifo), 
		.data_out(data_from_fifo), 
		.full(full), 
		.empt(empty)
	);
	
	
////////////////// Data Parsing /////////////
	
	//data_start_pos = Offset where the pixel array (bitmap data) can be found, should be 54 bytes
	//p_biBitCount = No of bit per pixel, should be 24
	reg  [15:0] file_size;
    reg  [3:0] 	counter 		= 0;
	reg  [5:0]	bytes_per_data 	= DATA_BUS_SIZE>>3; //How many bytes are in data bus
	reg  [25:0]	BMPcount 		= 0; 				//Count bytes being transfered
	reg  [1:0] 	whos_grt; 							//Which slave got the grant (whos_grt = 10 for neither)
	reg  [7:0] 	BMP [53:0]; 						//Register to hold the header
	
	////////Who's the chosen slave /////////
	assign whos_grt 		= (slv0_data_valid && (slv0_mode != 2'b00) && (slv0_mode != 2'b11))? 2'b00 :(slv1_data_valid && ((slv1_mode != 2'b00) && (slv1_mode != 2'b11 )))? 2'b01 : 2'b10;
	assign mode 			= (whos_grt == 2'b00)? slv0_mode:(whos_grt == 2'b01)? slv1_mode : 2'b00;
	assign data_proc 		= (whos_grt == 2'b00)? slv0_data_proc:(whos_grt == 2'b01)? slv1_data_proc : 8'b0;
		
	////////Get The FiFo Wired/////////////
	assign data_to_fifo 	= (whos_grt == 2'b00)? slv0_data : (whos_grt == 2'b01)? slv1_data : 'b0;
	//FiFo's wr is on from first input msg till end of headers (on TH mode)
	assign fifo_wr 			= (!rst_n && (mode == 2'b01) && (BMPcount < 54))? 'b1:'b0;
	//FiFo's rd is on from #DEAD_TIME after end of headers (on TH mode) till FiFo empty
	assign fifo_rd 			= (!rst_n && (mode == 2'b01) && (BMPcount > 53)&& (!empty))? 'b1:'b0;
	
	assign file_size 		= {BMP[5], BMP[4], BMP[3], BMP[2]};
	
	assign mstr0_data_valid = fifo_rd || mode[1];
	assign data_to_master 	= (mode[1])? data_out_pr : data_from_fifo;	
	assign mstr_ready 		= (slv0_data_valid || slv1_data_valid)? mstr0_ready:'b0; //if nothing is valid, dont do it
	
	always @(posedge clk, posedge rst_n)
	begin
	////////reseting first!/////////
		if (rst_n)
			begin
				data_to_processor 	<= 0;
				valid 				<= 0;
				done 				<= 0;
			end
	

		if (mstr0_ready && !rst_n)
			begin //158
				done = 0;
				if (whos_grt == 2'b00)
					begin
						if (BMPcount < 54) 
							begin
								valid 	<= 0;
								counter = 0;
								while (counter < bytes_per_data)//This while loop is for extracting input data byte by byte
									begin
										BMP[BMPcount] 		= slv0_data [counter * bytes_per_data +: 8];
										if (DEBUG) $display("BMP[%d] = %h\n", BMPcount, BMP[BMPcount]);
										BMPcount 			= BMPcount + 1;
										counter 			= counter + 1;
									end	
							end  //while (BMPcount < 54)
							
						if ((BMPcount >= 54) && (BMPcount < file_size))						 
								begin 
									valid = 0;
										//push new byte into output
										data_to_processor 	= slv0_data;
										BMPcount 			= BMPcount + 1;

										//output (after double checking) that data is valid
										valid = 1;
								end
						done = 1;

					end   //if (whos_grt == 0)
					
				if (whos_grt == 2'b01)
					begin
						if (BMPcount < 54) 
							begin
								valid 	<= 0;
								counter = 0;
								while (counter < bytes_per_data)//This while loop is for extracting input data byte by byte
									begin
										BMP[BMPcount] 		= slv1_data [counter * bytes_per_data +: 8];
										if (DEBUG) $display("BMP[%d] = %h\n", BMPcount, BMP[BMPcount]);
										BMPcount 			= BMPcount + 1;
										counter 			= counter + 1;
									end	
							end  //while (BMPcount < 54)
							
						if ((BMPcount >= 54) && (BMPcount < file_size))						 
								begin 
									valid = 0;
										//push new byte into output
										data_to_processor 	= slv1_data;
										BMPcount 			= BMPcount + 1;

										//output (after double checking) that data is valid
										valid = 1;
								end
						done = 1;

					end   //if (whos_grt == 0)
			end //78
		 //75
	end //67
endmodule