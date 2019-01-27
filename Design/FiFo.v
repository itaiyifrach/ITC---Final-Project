module FiFo
(
	clk, 
	rst, 
	rd, 
	wr, 
	data_in, 
	data_out, 
	full, 
	empt
);

	parameter DATA_BUS_SIZE = 32;
	parameter Data_Width 	= DATA_BUS_SIZE;
	parameter Addr_Width 	= 3;

	input 						clk;
	input 						rst;
	input 						rd;
	input 						wr;
	input      [Data_Width-1:0] data_in;
	output reg [Data_Width-1:0] data_out;
	
	output reg empt;
	output reg full;
	
	wire NOA = 2**Addr_Width; //MAX No of words FiFo can store
	wire next_rd = (rd);
	wire next_wr = (wr);
	
	wire rd_en;
	wire wr_en;

	//reg [Addr_Width-1:0] no_of_stored_data;

  reg  [Data_Width-1:0]mem[2**Addr_Width-1:0];
  reg  [Addr_Width:0]rd_addr_pos 	= 'd0; //pos values is to detect empty/full condition
  reg  [Addr_Width:0]wr_addr_pos 	= 'd0; //pos values is to detect empty/full condition

  integer i;

		assign empt  = (rd_addr_pos == wr_addr_pos)? 'd1:'d0;
		assign full  = ((rd_addr_pos[Addr_Width-1:0] == wr_addr_pos[Addr_Width-1:0])&& !empt)? 'd1:'d0;
		
		//assign no_of_stored_data 	= wr_addr_pos[Addr_Width-1:0] - rd_addr_pos[Addr_Width-1:0];
		assign rd_en 				= rd && !empt;
		assign wr_en 				= wr && !full;

      
	always@(posedge clk, posedge rst)
	begin
		if (rst)
			begin
				data_out 	<= 'd0;
				rd_addr_pos <= 0;
				wr_addr_pos <= 0;
				for (i=0;i<2**Addr_Width ;i=i+1)
					begin
						mem[i] <= 0;
					end
			end
		else
			begin				
              if (rd_en)			//Read Operation
					begin
						data_out 	<= mem [rd_addr_pos];
						rd_addr_pos <= rd_addr_pos + 'd1;
                        
					end
				if (wr_en)			//Write Operation
					begin
						mem [wr_addr_pos] <= data_in;
						wr_addr_pos 	  <= wr_addr_pos + 'd1;
					end
			end
	end
	endmodule
	