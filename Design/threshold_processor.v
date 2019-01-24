/*
-------------------------------------------------------------
------------------- THRESHOLD PROCESSOR ---------------------
-------------------------------------------------------------
This module calculates threshold of given pixels.

<------------------------- INPUTS -------------------------->
- clk			- clock
- rst_n			- reset
- vld			- determine if the data is valid
- last_data 	- indicates the last data_in
- mode			- determine which function to calculate:
    0: Nothing				(just passing data_in to data_out atm)
    1: Threshold
    2: Brightness
    3: For future function 	(just passing data_in to data_out atm)
- proc_val		- This is the threshold value or 
                      the added brightness value
- data_in		- incoming data

<------------------------- OUTPUTS -------------------------->
- data_out		- the calculated data

<------------------------ PARAMETERS ------------------------>
- DATA_WIDTH	- data width (32 or 64 bits)

-------------------------------------------------------------
*/


module threshold_processor(clk, rst_n, vld, last_data, mode, proc_val, data_in, data_out, data_out_rdy); 
  parameter DATA_WIDTH = 32;
  
  // set inputs and outputs
  input wire					clk;
  input wire					rst_n;
  input wire					vld;
  input wire					last_data;
  input wire [1:0] 				mode;
  input wire [`COLOR_SIZE-1:0] 	proc_val;
  input wire [DATA_WIDTH-1:0] 	data_in;
  output reg [DATA_WIDTH-1:0]	data_out;
  output reg					data_out_rdy;
  
  // set local variables
  reg [3*DATA_WIDTH-1:0]		threshold_array;
  reg [7:0]						counter;
  reg 							threshold_init;
  reg 							rdy_to_calc;
  
  
  always @(posedge clk or negedge rst_n) begin
    if (!rst_n || !vld) begin
      threshold_array 	<= 0;
      counter 			<= 0;
      threshold_init	<= 1;
      rdy_to_calc		<= 0;
      data_out			<= 0;
      data_out_rdy		<= 0;
    end
    
    // -------------------------
    // ------- THRESHOLD -------
    // -------------------------
    else if (vld) begin
      if (threshold_init) begin 		// filling the first 3*DATA_WIDTH bit array before pipeline
        threshold_array[counter*DATA_WIDTH+:DATA_WIDTH] = data_in;
        counter = counter + 1;
        if (counter == 3 || (last_data && counter < 3)) begin
          counter = 0;
          threshold_init = 0;
          rdy_to_calc = 1;			// after init, ready to calculate the threshold
        end
      end
      else begin
        if (rdy_to_calc) begin // if the 3*DATA_WIDTH bit array is full with valid pixels, calculate the threshold
          rdy_to_calc = 0;

          // ------- calculate the threshold function over 3*DATA_WIDTH bit array -------
          for(int i=0 ; i < 3*DATA_WIDTH/`PIXEL_SIZE ; i++) begin
            if ( (threshold_array[i*`PIXEL_SIZE+:`COLOR_SIZE] + threshold_array[i*`PIXEL_SIZE+`COLOR_SIZE+:`COLOR_SIZE] + threshold_array[i*`PIXEL_SIZE+2*`COLOR_SIZE+:`COLOR_SIZE]) / 3 > proc_val ) begin
              threshold_array[i*`PIXEL_SIZE+:`PIXEL_SIZE] = {`PIXEL_SIZE{1'b1}};
            end
            else begin
              threshold_array[i*`PIXEL_SIZE+:`PIXEL_SIZE] = {`PIXEL_SIZE{1'b0}};
            end
          end
          // ------- end of loop -------

          counter = 0;
        end		// end of rdy_to_calc
        // this is the pipeline in action - first release the data out, then fetch another data into same place
        data_out = threshold_array[counter*DATA_WIDTH+:DATA_WIDTH];
        threshold_array[counter*DATA_WIDTH+:DATA_WIDTH] = data_in;
        counter = counter + 1;
        data_out_rdy = 1;
        // if we done releasing all the data, that means we got valid pixels array which we can again calculate
        if (counter == 3) begin
          counter = 0;
          rdy_to_calc = 1;
        end
      end
    end
    // ---- END OF THRESHOLD ----
  end

  
endmodule : threshold_processor