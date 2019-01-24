//https://www.youtube.com/watch?v=8C1FqBMHzZg
//Ok So the latest idea is to create an array that has 54 cells, one byte each. that will hold the headers. after that to parse the important header data and send those along with the data
`timescale 1ns/1ns

//Need to know how the data is being inputed.

//Does requests should be saved???
`include "FiFo.v"

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
	parameter DEAD_TIME 	= 3; //Dead time in Threshold mode
    
	input clk;
    input rst_n;

////Slaves Shit/////
	input 						slv0_mode;
	input 						slv0_data_valid;
	input [DATA_BUS_SIZE - 1:0] slv0_data;
	input [7:0] 				slv0_data_proc;
	
	input 						slv1_mode;
	input 						slv1_data_valid;
	input [DATA_BUS_SIZE - 1:0] slv1_data;
	input [7:0] 				slv1_data_proc;


	
////Masters Shit/////
	input mstr0_ready;
	
	output reg [DATA_BUS_SIZE - 1:0] data_to_processor;  //Outputed data
	output reg [DATA_BUS_SIZE - 1:0] data_to_master;  //Outputed data

	output reg 						 valid;  // Signals that Outputed data on bus is valid
	output reg 						 done;	//Arbiter complete transfer req
	output reg						 mode;
	output reg [7:0] 				 data_proc;
	output reg [1:0] 				 mstr0_data_valid;
	
////FiFo Shit////////
	//reg [DATA_BUS_SIZE - 1:0] 	data_to_master;  //Outputed data
	reg [DATA_BUS_SIZE - 1:0] 	data_to_fifo;  //Inputed data which is DeadTime of header
	reg 						fifo_rd;
	reg 						fifo_wr;
	reg  						full;
	reg  						empty;

	FiFo fDUT 
	(
		.clk(clk), 
		.rst(rst_n), 
		.rd(fifo_rd), 
		.wr(fifo_wr), 
		.data_in(data_to_fifo), 
		.data_out(data_to_master), 
		.full(full), 
		.empt(empty)
	);
	
	
////////////////// Data Parsing /////////////////////
	
	//data_start_pos = Offset where the pixel array (bitmap data) can be found, should be 54 bytes
	//p_biBitCount = No of bit per pixel, should be 24
	reg [15:0] 	file_size;
    reg [3:0] 	counter 		= 0;
	reg [5:0]	bytes_per_data 	= DATA_BUS_SIZE>>3; 	//How many bytes are in data bus
	reg [19:0]	BMPcount 		= 0; 				//Count bytes being transfered
	//integer BMPcount = 0;
	reg [1:0] 	whos_grt; 							//Which slave got the grant (whos_grt = 10 for neither)
	reg [7:0] 	BMP [53:0]; 						//Register to hold the header
	
	
	/////////////FiFo Shit //////////////////
	always
	 @(posedge clk, posedge rst_n)
	 begin
		if ((slv0_mode == 2'b01) && mstr0_ready) //in case of TH mode, output data from FiFo after deadtime delay
			@(posedge clk) 
			begin
				 while (empty != 1)
				 #(DEAD_TIME);
				 fifo_rd <= 1;
				 mstr0_data_valid <= 1;
			 end
	 end
	
	
	always @(posedge clk, posedge rst_n)
	begin //160
		if (rst_n)
			begin
				data_to_processor 	<= 0;
				valid 				<= 0;
				done 				<= 0;
				fifo_rd				<= 0;
				fifo_wr				<= 0;
			end
		else
		begin//159
		//grants Logic - While (arbiter_is_free), The priority is to serve slave 0, Only if he doesnt have a req, slave1 is served. 
		if (mstr0_ready)
			begin //158
				whos_grt <= (slv0_data_valid && ((slv0_mode != 2'b00) && (slv0_mode != 2'b11)))? 2'b00 :(slv1_data_valid && ((slv1_mode != 2'b00) && (slv1_mode != 2'b11 )))? 2'b01 : 2'b10;
				//$display("slave%d was chosen\n", whos_grt);
				if (whos_grt == 0)
					begin
						done = 0;
						data_proc = slv0_data_proc;
						mode = slv0_mode;
						
						//start by recieving the header and extract file size from it
						while (BMPcount < 54)
							@(posedge clk) 
							begin
								fifo_rd = 0;
								valid = 0;
								counter = 0;
								while (counter < bytes_per_data)
									begin
										BMP[BMPcount] 		= slv0_data [counter * bytes_per_data +: 8];
										BMPcount 			= BMPcount + 1;
										if (BMPcount == 6) file_size = {BMP[5], BMP[4], BMP[3], BMP[2]};
										counter 			= counter + 1;
									end	
							if (slv0_mode == 2'b10) data_to_master = slv0_data;
							if (slv0_mode == 2'b01) //in case of TH mode, save header data in FiFo
								begin
									data_to_fifo = slv0_data;
									fifo_wr = 1;
								end
							end  //while (BMPcount < 54)
							
						$display("file_size = %d\n", file_size);
						while (BMPcount < file_size)
							@(posedge clk) 
								begin 
									fifo_wr = 0;
									valid = 0;
										//push new byte into output
										data_to_processor = slv0_data;
	
										//output (after double checking) that data is valid
										valid = 1;
								end
						done = 1;
						#(DEAD_TIME);
						mstr0_data_valid = 2'b00;
						
					end   //if (whos_grt == 0)
					
				if (whos_grt == 1)
					begin
						done = 0;
						data_proc = slv1_data_proc;
						mode = slv1_mode;
						
						//start by recieving the header and extract file size from it
						while (BMPcount < 54)
							@(posedge clk) 
							begin
								fifo_rd = 0;
								valid = 0;
								counter = 0;
								while (counter < bytes_per_data)
									begin
										BMP[BMPcount] 		= slv1_data [counter * bytes_per_data +: 8];
										BMPcount 			= BMPcount + 1;
										if (BMPcount == 6) file_size = {BMP[5], BMP[4], BMP[3], BMP[2]};
										counter 			= counter + 1;
									end	
							if (slv1_mode == 2'b10) data_to_master = slv1_data;
							if (slv1_mode == 2'b01) //in case of TH mode, save header data in FiFo
								begin
									data_to_fifo = slv1_data;
									fifo_wr = 1;
								end
							end  //while (BMPcount < 54)
							
						$display("file_size = %d\n", file_size);
						while (BMPcount < file_size)
							@(posedge clk) 
								begin 
									fifo_wr = 0;
									valid = 0;
										//push new byte into output
										data_to_processor = slv1_data;
	
										//output (after double checking) that data is valid
										valid = 1;
								end
						done = 1;
						#(DEAD_TIME);
						mstr0_data_valid = 2'b10;

					end   //if (whos_grt == 0)
			end //78
		end //75
	end //67
endmodule