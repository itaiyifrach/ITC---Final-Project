// defines
`ifndef DATA_WIDTH
 `define DATA_WIDTH 32
`endif
`define COLOR_SIZE 8
`define PIXEL_SIZE 24

// includes
`include "uvm_macros.svh"
import uvm_pkg::*;
`include "dut_if.sv"
`include "full_transaction.sv"
`include "master_transaction.sv"
`include "slave_transaction.sv"
`include "test.sv"
`include "image_processing_accelerator.v"


module testbench;
  
  initial begin
    $dumpfile("dump.vcd");
    $dumpvars(0);
  end
  
  dut_if dut_if1();
  image_processing_acclerator #(.DATA_WIDTH(`DATA_WIDTH)) img_proc_acc (
    .clk				(dut_if1.clk),
    .rst_n				(dut_if1.rst_n),
    .slv0_mode			(dut_if1.slv0_mode),
    .slv0_data_valid	(dut_if1.slv0_data_valid),
    .slv0_proc_val		(dut_if1.slv0_proc_val),
    .slv0_data			(dut_if1.slv0_data),
    .slv0_ready			(dut_if1.slv0_rdy),
    .slv1_mode			(dut_if1.slv1_mode),
    .slv1_data_valid	(dut_if1.slv1_data_valid),
    .slv1_proc_val		(dut_if1.slv1_proc_val),
    .slv1_data			(dut_if1.slv1_data),
    .slv1_ready			(dut_if1.slv1_rdy),
    .mstr0_cmplt		(dut_if1.mstr0_cmplt),
    .mstr0_ready		(dut_if1.mstr0_ready),
    .mstr0_data			(dut_if1.mstr0_data),
    .mstr0_data_valid	(dut_if1.mstr0_data_valid)
     );
  
  // clock generator
  initial begin
    dut_if1.clk = 0;
    forever #5 dut_if1.clk = ~dut_if1.clk;
  end

  // reset generation
  initial begin
    //$display("\n---- START OF RESET ----\n");
    dut_if1.rst_n = 0;
    #6 dut_if1.rst_n = 1;
    //$display("\n---- END OF RESET ----\n");
  end
  
  initial begin
    uvm_config_db #(virtual dut_if)::set(null, "*", "dut_if_db", dut_if1);
    run_test("test");
  end
  
  
endmodule