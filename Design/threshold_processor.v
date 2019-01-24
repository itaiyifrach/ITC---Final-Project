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
- data_out_vld	- indicates if the data_out is valid
- done			- indicated when finished processing all the data

<------------------------ PARAMETERS ------------------------>
- DATA_WIDTH	- data width (32 or 64 bits)

-------------------------------------------------------------
*/


module threshold_processor(clk, rst_n, vld, last_data, mode, proc_val, data_in, data_out, data_out_vld, done); 
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
  output reg					data_out_vld;
  output reg					done;
  
  // set local variables
  reg [3*DATA_WIDTH-1:0]		threshold_array;
  reg [7:0]						counter;
  reg [15:0]					calc_until;
  reg 							threshold_init;
  reg							last_in_init;
  reg 							rdy_to_calc;
  reg							delay;
  reg [2:0]						delay_count;
  
  
  always @(posedge clk or negedge rst_n) begin
    if (!rst_n || done) begin			// CHECK THIS WHEN RECIEVING A NEW FILE
      threshold_array 	<= 0;
      counter 			<= 0;
      calc_until		<= 0;
      threshold_init	<= 1;
      last_in_init		<= 0;
      rdy_to_calc		<= 0;
      data_out			<= 0;
      data_out_vld		<= 0;
      delay				<= 0;
      delay_count		<= 0;
      done				<= 0;
    end
    
    // -------------------------
    // ------- THRESHOLD -------
    // -------------------------
    else if (vld || delay) begin
      
      // decreasing the delay count. If reached to 1, then all data is out
      delay_count = delay ? delay_count - 1 : delay_count;
      if (delay_count == 1) done = 1;
      $display("Threshold Array =\t\t %0h", threshold_array);
      
      if (threshold_init) begin 		// filling the first 3*DATA_WIDTH bit array before pipeline
        threshold_array[counter*DATA_WIDTH+:DATA_WIDTH] = data_in;
        counter = counter + 1;
        if (last_data && (counter < 3)) begin	// if got last_data before filling the array
          delay = 1;
          last_in_init = 1;
          delay_count = counter[2:0] + 1;
          threshold_init = 0;
          rdy_to_calc = 1;
        end
        if (counter == 3) begin
          counter = 0;
          if (last_data) begin	// if got last_data exactly when the array was fully filled
            delay_count = 4;
            delay = 1;
          end
          threshold_init = 0;
          rdy_to_calc = 1;			// after init, ready to calculate the threshold
        end
      end
      else begin
        if (rdy_to_calc) begin // if the 3*DATA_WIDTH bit array is full with valid pixels, calculate the threshold
          rdy_to_calc = 0;
          calc_until = (counter == 0) ? 3*DATA_WIDTH/`PIXEL_SIZE : counter*DATA_WIDTH/`PIXEL_SIZE;
          // ------- calculate the threshold function over 3*DATA_WIDTH bit array -------
          for(int i=0 ; i < calc_until ; i++) begin
            if ( (threshold_array[i*`PIXEL_SIZE+:`COLOR_SIZE] + threshold_array[i*`PIXEL_SIZE+`COLOR_SIZE+:`COLOR_SIZE] + threshold_array[i*`PIXEL_SIZE+2*`COLOR_SIZE+:`COLOR_SIZE]) / 3 > proc_val ) begin
              threshold_array[i*`PIXEL_SIZE+:`PIXEL_SIZE] = {`PIXEL_SIZE{1'b1}};
            end
            else begin
              threshold_array[i*`PIXEL_SIZE+:`PIXEL_SIZE] = {`PIXEL_SIZE{1'b0}};
            end
          end
          // ------- end of loop -------

          if (!delay || last_in_init) counter = 0;
        end		// end of rdy_to_calc
        $display("Threshold Array After Calc =\t %0h", threshold_array);
        // this is the pipeline in action - first release the data out, then fetch another data into same place
        if (vld || delay) data_out = threshold_array[counter*DATA_WIDTH+:DATA_WIDTH];
        $display("Data Out =\t\t\t %0h", data_out);
        if (vld) threshold_array[counter*DATA_WIDTH+:DATA_WIDTH] = data_in;
        counter = counter + 1;
        data_out_vld = 1;
        
        if (last_data && !last_in_init) begin
          delay = 1;
          delay_count = 4;
          rdy_to_calc = 1;
        end
        if (last_in_init) last_in_init = 0;
        // if we done releasing all the data, that means we got valid pixels array which we can again calculate
        if (counter == 3) begin
          counter = 0;
          if (!delay) rdy_to_calc = 1;
        end
      end
    end