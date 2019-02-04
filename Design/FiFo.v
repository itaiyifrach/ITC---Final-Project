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
	
	
	wire rd_en;
	wire wr_en;
	

    reg  [Data_Width-1:0]mem[2**Addr_Width-1:0];
    reg  [Addr_Width:0]rd_addr_pos 	= 'd0;
    reg  [Addr_Width:0]wr_addr_pos 	= 'd0;

    integer i = 0;

	assign empt  = (rd_addr_pos == wr_addr_pos);
	assign full  = ((rd_addr_pos[Addr_Width-1:0] == wr_addr_pos[Addr_Width-1:0]) && (rd_addr_pos[Addr_Width] != wr_addr_pos[Addr_Width]) );
	
	assign rd_en = (rd && !empt)||(rd && wr);
	assign wr_en = (wr && !full)||(rd && wr);

      
	always@(posedge clk, negedge rst)
	begin
		if (!rst)
			begin
				data_out 	<= 'd0;
				rd_addr_pos <= 'd0;
				wr_addr_pos <= 'd0;
				for (i=0;i<2**Addr_Width ;i=i+1)
					begin
						mem[i] <= 'd0;
					end
			end
		else
			begin
			if (wr_en)			//Write Operation
				begin
					mem [wr_addr_pos[Addr_Width-1:0]] 	<= data_in;
					wr_addr_pos 	  					<= wr_addr_pos + 'd1;
				end			
			if (rd_en)			//Read Operation
				begin
					data_out 							<= mem [rd_addr_pos[Addr_Width-1:0]];
					rd_addr_pos 						<= rd_addr_pos + 'd1;
					
				end

			end
	end
	endmodule
	