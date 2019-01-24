// Code your testbench here
// or browse Examples
`timescale 1ns/1ns

`include "FiFo.v"
module testbench();

	parameter DEBUG			= 0;
	parameter PERIOD 		= 10;
	parameter DATA_BUS_SIZE = 32;
	parameter BYTE			= 8;
	reg 						clk;
	reg 						rst_n;
	reg							slv0_mode;
	reg 						slv0_data_valid;
	reg	[DATA_BUS_SIZE - 1:0] 	slv0_data;
	reg [7:0] 					slv0_data_proc;
	reg							slv1_data_mode;
	reg 						slv1_data_valid; 
	reg	[DATA_BUS_SIZE - 1:0] 	slv1_data;
	reg [7:0] 					slv1_data_proc;
	reg 						mstr0_ready;
	wire[DATA_BUS_SIZE - 1:0] 	data_to_processor;
	wire[DATA_BUS_SIZE - 1:0] 	data_to_master;
	wire[DATA_BUS_SIZE - 1:0] 	data_to_fifo;
	wire 						fifo_rd;
	wire 						fifo_wr;
	wire 						valid;
	wire 						done;
	wire 						full;
	wire 						empty;
	wire						mode;
	wire [7:0] 					data_proc;
	wire [1:0]					mstr0_data_valid;
	
	bmp_arbiterBFF DUT (
		.clk(clk),
		.rst_n(rst_n),
		
		.slv0_mode(slv0_mode),
		.slv0_data_valid(slv0_data_valid),
		.slv0_data(slv0_data),
		.slv0_data_proc(slv0_data_proc),
		
		.slv1_mode(slv1_mode),
		.slv1_data_valid(slv1_data_valid), 
		.slv1_data(slv1_data),
		.slv1_data_proc(slv1_data_proc),
		.mstr0_ready(mstr0_ready),
		.mstr0_data_valid(mstr0_data_valid),
		.data_to_processor(data_to_processor),
		.data_to_master(data_to_master),
		.valid(valid),
		.mode(mode),
		.data_proc(data_proc),
		
		
		.done(done)
	);
	
	// FiFo fDUT (
	// .clk(clk), 
	// .rst_n(rst_n), 
	// .rd(fifo_rd), 
	// .wr(fifo_wr), 
	// .data_in(data_to_fifo), 
	// .data_out(data_to_master), 
	// .full(full), 
	// .empt(empty));
	
	//FiFo fDUT (clk, rst_n, fifo_rd, fifo_wr, data_to_fifo, data_to_master, full, empty);
	
	
	`define read_file_name "hex.txt"
	localparam BMP_ARRAY_LEN = 64'd1000000; //file max size in bytes
	integer   bytes_per_data 	= DATA_BUS_SIZE/8; 	//How many bytes are in data bus
	reg [2:0] rest_of_bytes;
	integer counter = 0;
	integer BMPcount = 0;
	integer file_size, data_start_pos, p_width, p_height;
	reg [15:0] p_biBitCount;
	reg  [7:0] bmp_data [BMP_ARRAY_LEN-1:0];

	
	initial
		begin
			slv0_mode = 2'b01;
			if (DEBUG) $display("Loading bmp file!\n");
			$readmemh("C:/Users/Abu Tony/Desktop/McFly/MEGAsync/Design Verification /VerliLog/PRoj/export.txt", bmp_data);

		    file_size <= {bmp_data[5], bmp_data[4], bmp_data[3], bmp_data[2]};
			$display("file size is %d", file_size);
					
					
			data_start_pos 	<= {bmp_data[13], bmp_data[12], bmp_data[11], bmp_data[10]};
			if (DEBUG) $display("data_start_pos = %d\n", data_start_pos);
			
			p_width 		<= {bmp_data[21], bmp_data[20], bmp_data[19], bmp_data[18]};
			if (DEBUG) $display("p_width = %d\n", p_width);

			p_height 		<= {bmp_data[25], bmp_data[24], bmp_data[23], bmp_data[22]};
			if (DEBUG) $display("p_height = %d\n", p_height);
			
			p_biBitCount 	<= {bmp_data[29], bmp_data[28]};
			if (DEBUG) $display("p_biBitCount = %d\n", p_biBitCount);
			//	end
		end
			
	initial clk = 1'b1;
	always #(PERIOD/2) clk = ~clk;
	
	initial
	begin
		$dumpfile("Memory.vcd");
		$dumpvars;
	end
	
	//Reset Logic
	event reset_trigger;
	event reset_done_trigger;

	initial 
	begin
		forever
		begin
		@(reset_trigger);
		@(posedge clk);
		rst_n = 1;
		slv1_data_valid = 0;
        if (DEBUG) $display("Im in the middle of my reset!!!");
		slv0_data_valid = 0;
		mstr0_ready = 0;		
		#3;
		@(posedge clk);
		rst_n = 0;
		mstr0_ready = 1;		
		->reset_done_trigger;
		end
	end
	
	//Verification Plan
	initial 
	begin
	->reset_trigger;
	@(reset_done_trigger)
	while (BMPcount < file_size)
		@(negedge clk) //write 
		begin
			counter = 0;
			slv0_data_valid = 32'b0;
			while (counter < bytes_per_data)
				begin
					slv0_data [(counter * BYTE) +: BYTE] <= bmp_data[BMPcount];
					if (DEBUG) $display ("Byte no %d is : %b", BMPcount, bmp_data[BMPcount]);
					if (DEBUG) $display ("This what the DUT got in this round: %b", slv0_data[(counter * BYTE) +: 8]);

					BMPcount 			= BMPcount + 1;
					counter 			= counter + 1;
				end
			slv0_data_valid = 1;
			
			if (DEBUG) $display ("This what the DUT got: %b", slv0_data);

		end
		while (BMPcount < file_size) 
			begin
				rest_of_bytes = file_size - BMPcount;
				counter = 0;
				slv0_data [(counter * BYTE) +: BYTE] = bmp_data[BMPcount];
				if (DEBUG) $display ("Byte no %d is : %b", BMPcount, bmp_data[BMPcount]);
				if (DEBUG) $display ("This what the DUT got in this round: %b", slv0_data[(counter * BYTE) +: 8]);

				BMPcount 			= BMPcount + 1;
				counter 			= counter + 1;
			end
//////*********$#%^&* need to decide what to put in rest of bus#@%@^*****//////////			
			slv0_data_valid = 1;

		$finish;

	end

  	//$display("file_size = %d bytes\n", file_size);			
endmodule