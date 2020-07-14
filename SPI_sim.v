
`timescale 1ns / 1ns

module tb;
  reg clk, MISO;
  wire MOSI,SCK,CS,DATA_VALID;
  wire [11:0] o_DATA;
  
  always #4 clk = ~clk;
  
  // MISO word to transmit 1st = 12'b110101110011 or 12'hD73
  // MISO word to transmit 2nd = 12'b000000000011 or 12'h3
  
  SPI_state_machine uut(clk,MISO,MOSI,SCK,o_DATA,CS,DATA_VALID);
  
  initial 
    begin 
      //$dumpfile("dump.vcd");        // for EDAplayground only
      //$dumpvars(0,uut);
      clk=0;
      MISO=1'bz;
      #24944     // initialize and disable time
      MISO=1'bz;
      #6632      // Transmit time 
      MISO=1;    // null bit
      #1408      // one SCK cycle in ns
      MISO=1;    // bit #11
      #1408
      MISO=1;    // 10
      #1408
      MISO=0;    // 9
      #1408
      MISO=1;    // 8
      #1408
      MISO=0;    // 7
      #1408
      MISO=1;    // 6
      #1408
      MISO=1;    // 5
      #1408
      MISO=1;    // 4
      #1408
      MISO=0;    // 3
      #1408
      MISO=0;    // 2
      #1408
      MISO=1;    // 1
      #1408
      MISO=1;	 // 0
      #8040      // Transmit time 
      MISO=1;    // null bit
      #1408      // one SCK cycle in ns
      MISO=0;    // bit #11
      #1408
      MISO=0;    // 10
      #1408
      MISO=0;    // 9
      #1408
      MISO=0;    // 8
      #1408
      MISO=0;    // 7
      #1408
      MISO=0;    // 6
      #1408
      MISO=0;    // 5
      #1408
      MISO=0;    // 4
      #1408
      MISO=0;    // 3
      #1408
      MISO=0;    // 2
      #1408
      MISO=1;    // 1
      #1408
      MISO=1;    // 0 
      #1408
	    MISO=1'bz; // high impedance (models actual chip)
	  #5000
      $finish;
    end
endmodule
