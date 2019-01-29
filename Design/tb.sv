`include "image_processing_acclerator.v"

module test;
  
    parameter DATA_WIDTH = 32;
  	parameter DEBUG			= 1 ;
	parameter PERIOD 		= 10;
	parameter DATA_BUS_SIZE = 32;
	parameter BYTE			= 8;
	parameter DEAD_TIME		= 3;
  
  logic 					clk 	= 0;
  logic 					rst_n 	= 0;
  logic [1:0] 				slv0_mode;
  logic 					slv0_data_valid;
  logic [`COLOR_SIZE-1:0] 	slv0_proc_val;
  logic [DATA_WIDTH-1:0] 	slv0_data;
  logic 					slv0_ready;
  logic [1:0] 				slv1_mode;
  logic 					slv1_data_valid;
  logic [`COLOR_SIZE-1:0] 	slv1_proc_val;
  logic [DATA_WIDTH-1:0] 	slv1_data;
  logic 					slv1_ready;
  logic 					mstr0_cmplt;
  logic 					mstr0_ready;
  logic [DATA_WIDTH-1:0] 	mstr0_data;
  logic [1:0] 				mstr0_data_valid;
  
  	

	localparam   BMP_ARRAY_LEN 	= 64'd1000000; //file max size in bytes
	integer   	 bytes_per_data 	= DATA_BUS_SIZE/8; 	//How many bytes are in data bus
	reg [2:0] 	 rest_of_bytes;
	integer 	 counter 		= 0;
	integer 	 BMPcount 		= 0;
	integer 	 file_size, data_start_pos, p_width, p_height;
	reg [15:0] 	 p_biBitCount;
	//reg [7:0] 	 bmp_data [BMP_ARRAY_LEN-1:0];
	reg [7:0] 	 bmp_data [0:BMP_ARRAY_LEN-1];

	
	initial
		begin
			slv0_mode = 2'b01;
			if (DEBUG) $display("Loading bmp file!\n");
			$readmemh("C:/Users/Abu Tony/Desktop/X/ITC---Final-Project/Design/export.txt", bmp_data);

		    file_size <= {bmp_data[5], bmp_data[4], bmp_data[3], bmp_data[2]};
			#10;
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
			
  
  initial begin
    $dumpfile("processor.vcd");
    $dumpvars;
  end
  
  // clock generator
  always begin
   	#5 clk = ~clk;
  end
  
  initial begin
    rst_n = 1;
    #7 rst_n = ~rst_n;
    #7 rst_n = ~rst_n;
  end
  
  // create the DUT
  image_processing_acclerator #(.DATA_WIDTH(DATA_WIDTH)) img_proc_acc (
    .clk				(clk),
    .rst_n				(rst_n),
    .slv0_mode			(slv0_mode),
    .slv0_data_valid	(slv0_data_valid),
    .slv0_proc_val		(slv0_proc_val),
    .slv0_data			(slv0_data),
    .slv0_ready			(slv0_ready),
    .slv1_mode			(slv1_mode),
    .slv1_data_valid	(slv1_data_valid),
    .slv1_proc_val		(slv1_proc_val),
    .slv1_data			(slv1_data),
    .slv1_ready			(slv1_ready),
    .mstr0_cmplt		(mstr0_cmplt),
    .mstr0_ready		(mstr0_ready),
    .mstr0_data			(mstr0_data),
    .mstr0_data_valid	(mstr0_data_valid)
     );
  
  initial begin
    #150 $finish;
  end
  
  			
	//initial clk = 1'b1;
	//always #(PERIOD/2) clk = ~clk;
	
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
		rst_n = 0;
		slv1_data_valid = 0;
        if (DEBUG) $display("Im in the middle of my reset!!!");
		slv0_data_valid = 0;
		mstr0_ready = 0;		
		#3;
		@(posedge clk);
		rst_n = 1;
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
			slv0_data_valid = 'b0;
			while (counter < bytes_per_data)
				begin
					slv0_data [(counter * BYTE) +: BYTE] <= bmp_data[BMPcount];
					if (DEBUG) $display ("Byte no %d is : %b", BMPcount, bmp_data[BMPcount]);
					if (DEBUG) $display ("This what the DUT got in this round: %b", slv0_data[(counter * BYTE) +: 8]);

					BMPcount 			= BMPcount + 1;
					counter 			= counter + 1;
				end
			slv0_data_valid = 'b1;
			
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
	
			slv0_data_valid = 1;
			
		if (BMPcount == file_size)
			
		$finish;

	end
endmodule