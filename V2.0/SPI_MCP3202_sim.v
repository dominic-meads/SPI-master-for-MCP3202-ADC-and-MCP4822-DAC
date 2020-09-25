`timescale 1ns / 1ns

module tb;
  reg clk, EN, MISO;
  wire MOSI,SCK,CS,DATA_VALID;
  wire [11:0] o_DATA;
  
  always #4 clk = ~clk;
  
  localparam SGL = 1;  // single-ended mode
  localparam ODD = 0;  // Data Aquisition on Channel 0
  
  // MISO word to transmit 1st = 12'b110101110011 or 12'hD73
  
  SPI_MCP3202 #(SGL,ODD) uut (clk,EN,MISO,MOSI,SCK,o_DATA,CS,DATA_VALID);
  
  initial 
    begin 
      //$dumpfile("dump.vcd");        // for EDAplayground only
      //$dumpvars(0,uut);
      clk=0;
      EN = 1;
      MISO=1'bz;
      #512       // disable time
      MISO=1'bz;
      #4200      // Transmit time
      //EN = 0;    // Enable test during transmit state
      #168
      //EN = 1;    // Enable test during transmit state
      MISO=1;    // null bit
      #1120      // one SCK cycle in ns
      MISO=1;    // bit #11
      #1120
      MISO=1;    // 10
      #1120
      MISO=0;    // 9
      #1120
      MISO=1;    // 8
      #1120
      MISO=0;    // 7
      //EN = 0;   // test enable (it works)
      #1120
      MISO=1;    // 6
      #1120
      //EN = 1;   // see if enable returns to disable state
      MISO=1;    // 5
      #1120
      MISO=1;    // 4
      #1120
      MISO=0;    // 3
      #1120
      MISO=0;    // 2
      #1120
      MISO=1;    // 1
      #1120
      MISO=1;	 // 0
	  #1120
	  MISO=1'bz;  // datasheet says the chip will be in a high impedance state when MISO is not active
	  #5000
      $finish;
    end
endmodule
