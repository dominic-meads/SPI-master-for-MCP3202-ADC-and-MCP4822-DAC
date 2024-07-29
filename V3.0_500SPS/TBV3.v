`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 07/13/2024 10:44:56 PM
// Design Name: 
// Module Name: TBV3
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


`timescale 1ns / 1ns

module tb;
  reg clk, rst_n, miso;
  wire mosi, sck, cs, dv;
  wire [11:0] data;
  
  always #4 clk = ~clk;
  
  localparam FCLK = 125e6; // clk frequency
  localparam SGL  = 1;     // single-ended mode
  localparam ODD  = 0;     // Data Aquisition on Channel 0
  
  reg [11:0] r_tst_smpl = 12'hd73; // miso test sample word 
  
  SPI_MCP3202_V3 #(FCLK,SGL,ODD) uut (clk, rst_n, miso, mosi, sck, cs, data, dv);
  
  initial 
    begin 
      clk   = 1'b0;
      rst_n = 1'b0;
      miso  = 1'bz;
      #25
      rst_n = 1'b1;
      wait (~cs)
        begin 
          #3600 // sample in middle of first sck cycle
          if (mosi == 1'b1)
            $display("START bit received");
          #7200
          if (mosi == 1'b1)
            $display("set to single-ended mode");
          else
            $display("set to differential mode");
          #7200
          if (mosi == 1'b1)
            $display("sampling on channel 1");
          else
            $display("sampling on channel 0");
          #7200
          if (mosi == 1'b1)
            $display("set to MSBF mode");
          else
            $display("set to LSBF mode");
          #3600
          miso = r_tst_smpl[11];
          #7200
          miso = r_tst_smpl[10];
          #7200
          miso = r_tst_smpl[9];
          #7200
          miso = r_tst_smpl[8];
          #7200
          miso = r_tst_smpl[7];
          #7200
          miso = r_tst_smpl[6];
          #7200
          miso = r_tst_smpl[5];
          #7200
          miso = r_tst_smpl[4];
          #7200
          miso = r_tst_smpl[3];
          #7200
          miso = r_tst_smpl[2];
          #7200
          miso = r_tst_smpl[1];
          #7200
          miso = r_tst_smpl[0];
          #50000
          $finish;
        end
    end
endmodule
