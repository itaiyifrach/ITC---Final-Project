module FiFo(
	clk, 
	rst, 
	rd, 
	wr, 
	data_in, 
	data_out, 
	full, 
	empt);

parameter DATA_BUS_SIZE = 32;
parameter Data_Width = DATA_BUS_SIZE;
parameter Addr_Width = 3;

	input clk;
	input rst;
	input rd;
	input wr;
	input [Data_Width-1:0] data_in;
	output reg [Data_Width-1:0] data_out;
	
	output reg empt;
	output reg full;
	
	wire next_rd = (rd);
	wire next_wr = (wr);
	reg rd_en;
	reg wr_en;


	reg  [Addr_Width-1:0]rd_addr = 0;
	reg  [Addr_Width-1:0]wr_addr = 0;
	reg  [Data_Width-1:0]mem[2**Addr_Width-1:0];
	reg  [Addr_Width:0]rd_addr_pos = 0;
	reg  [Addr_Width:0]wr_addr_pos = 0;

	integer i;
	
	initial 
	begin
	empt = 1;
	full = 0;
	end
	always@(posedge clk, posedge rst)
	begin
		if (rst)
			begin
				data_out <= 0;
				full <= 0;
				empt <= 1;
				rd_addr <= 0;
				wr_addr <= 0;
				rd_addr_pos <= 0;
				wr_addr_pos <= 0;
				for (i=0;i<2**Addr_Width ;i=i+1)
					begin
						mem[i] <= 0;
					end
			end
		else
			if (((wr_addr - rd_addr) == 0))
				begin
				if (rd_addr_pos == wr_addr_pos) 
				begin
				empt <= 1;
				rd_addr_pos = 0;
				wr_addr_pos = 0;
				end
				else
				begin
				full <= 1;
				end
			end
				
		
			rd_en <= next_rd && !empt;
			wr_en <= next_wr && !full;
			
			if (rd_en)			//Read Operation
				begin
					data_out <= mem[rd_addr];
					rd_addr <= (rd_addr +1)%2**Addr_Width;
					rd_addr_pos <= rd_addr_pos +1;
					full <= 0;
				end
			if (wr_en)			//Write Operation
				begin
					mem[wr_addr] <= data_in;
					wr_addr <= (wr_addr + 1)%2**Data_Width;
					wr_addr_pos <= wr_addr_pos + 1;
					empt <= 0;
				end

			end
	endmodule
	