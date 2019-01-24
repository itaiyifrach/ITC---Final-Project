endmodule : processor

/*
-------------------------------------------------------------
------------------ BRIGHTNESS PROCESSOR ---------------------
-------------------------------------------------------------
This module calculates threshold and brightness of given
pixels.

<------------------------- INPUTS -------------------------->
- clk			- clock
- rst_n			- reset
- vld			- determine if the data is valid
- last_data		- determine if the data_in is the last data
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


module brightness_processor(clk, rst_n, vld, last_data, mode, proc_val, data_in, data_out, data_out_vld, done); 
  parameter DATA_WIDTH = 32;
  
  // set inputs and outputs
  input wire					clk;
  input wire					rst_n;
  input wire					vld;
  input wire					last_data;
  input wire [1:0] 				mode;
  input wire [`COLOR_SIZE-1:0] 	proc_val;
  input wire [DATA_WIDTH-1:0] 	data_in;
  output reg [DATA_WIDTH-1:0] 	data_out;
  output reg					data_out_vld;
  output reg					done;
  
  // set local variables
  reg [DATA_WIDTH-1:0]			brightness_array;
  reg [`COLOR_SIZE:0] 			brightness_val;		// save addition bit to detect overflow
  
  always @(posedge clk or negedge rst_n) begin
    if (!rst_n || !vld) begin
      brightness_array 	<= 0;
      brightness_val	<= 0;
      data_out			<= 0;
      data_out_vld		<= 0;
    end
    
    // --------------------------
    // ------- BRIGHTNESS -------
    // --------------------------
    else if (vld) begin
      for(int i=0 ; i < DATA_WIDTH/`COLOR_SIZE ; i++) begin
        brightness_val = data_in[i*`COLOR_SIZE+:`COLOR_SIZE] + proc_val;
        brightness_array[i*`COLOR_SIZE+:`COLOR_SIZE] = brightness_val[`COLOR_SIZE-1:0];

        // if the new color value is negative, then assign 0
        if ($signed(proc_val) < 0 && $signed(data_in[i*`COLOR_SIZE+:`COLOR_SIZE] + proc_val) < 0) begin
          brightness_array[i*`COLOR_SIZE+:`COLOR_SIZE] = {(`COLOR_SIZE){1'b0}};
        end
        // if the new color value is positive, then assign 255
        if (brightness_val[`COLOR_SIZE] == 1) begin
          brightness_array[i*`COLOR_SIZE+:`COLOR_SIZE] = {(`COLOR_SIZE){1'b1}};
        end
      end	
      // ------- end of loop -------
      data_out = brightness_array;
      data_out_vld = 1;
      assign done = last_data ? 1 : 0;
    end
    // --- END OF BRIGHTNESS ----
  end
  
endmodule : brightness_processor