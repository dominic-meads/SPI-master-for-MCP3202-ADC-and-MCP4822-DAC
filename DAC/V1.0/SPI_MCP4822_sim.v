`timescale 1ns / 1ps

module tb;
	reg clk;              // 125 MHz
	reg Tx;               // single pulse to show when data ready to be sent out
	reg [11:0] i_DATA;    // Data to be serialized and sent to DAC
	wire SCK;             // SPI clk
	wire MOSI;        	  // Serial data into DAC
	wire LDAC;        	  // Latch DAC wire
	wire CS;          	  // Chip select
	wire CC;           	  // conversion complete feedback flag
	
	always #4 clk = ~clk;

	SPI_MCP4822 uut(clk,Tx,i_DATA,SCK,MOSI,LDAC,CS,CC);

	initial 
		begin 	
			$dumpfile("dump.vcd");
			$dumpvars(0,uut);
			clk = 0;
			Tx = 0;
			i_DATA = 12'hFD8;
			#2000
			Tx = 1;
			#25000
			$finish;
		end
endmodule
			
			
