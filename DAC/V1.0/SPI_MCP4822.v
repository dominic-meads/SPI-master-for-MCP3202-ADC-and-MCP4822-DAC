`timescale 1ns / 1ps

module SPI_MCP4822 #(
	parameter AB = 1'b1,       // Low for channel A output, high for channel B
	parameter BUF = 1'b0,      // high enables data buffer, low means disabled 
	parameter GA = 1'b1,       // low for 2x gain, high for 1x gain (with respect to Vref)
	parameter SHDN = 1'b1      // low means shutdown, high means chip is active
    )(
	input clk,              // 125 MHz
	input Tx,               // single pulse to show when data ready to be sent out
	input [11:0] i_DATA,    // Data to be serialized and sent to DAC
	output SCK,             // SPI clk
	output reg MOSI,        // Serial data into DAC
	output LDAC,            // Latch DAC output
	output reg CS,          // Chip select
	output reg CC           // conversion complete feedback flag
	);
	
	// states 
	localparam IDLE = 0;  // CS high
	localparam SEND = 1;  // CS low, serialize and send data
	
	// registers
	reg STATE = 0;                     // keeps track of state machine
	reg [15:0] DATA_concat = 0;        // concatenation for all the data to be sent out
	reg [6:0] SCK_count = 0;           // counter to determine period of SPI clk
	reg SCK_count_EN = 0;              // enable for ^
	reg [11:0] conversion_count = 0;   // keeps track of the timing for the entire 20us conversion

	integer i = 0;  // for loop

	
	/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	// conversion counter
	always @ (posedge clk)
		begin 
			if (Tx)
				begin 
					if (conversion_count <= 2498)  // 2500 counts for a conversion @ 8ns per count is 20 us or 50 KHz 
						conversion_count <= conversion_count + 1;
					else 
						conversion_count <= 0;
				end  // if (Tx)
			else 
				conversion_count <= 0;
		end  // always
	// end conversion counter
	
	/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	// SCK generation
	
	always @ (posedge clk)
		begin 
			if (SCK_count_EN)
				begin
					if (SCK_count <= 122) 
						SCK_count <= SCK_count + 1;  // SCK period is 124 counts (0-123) @ 8ns each, or 1.008 MHz (< max of 20 MHz)
					else 
						SCK_count <= 0;
				end  // if (SCK_count_EN)
			else 
				SCK_count <= 0;
		end  // always 
	
	assign SCK = (SCK_count <= 61) ? 0:1;  // 50% duty cycle PWM
	// end SCK generation	
	
	/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	// Latch DAC output	
	assign LDAC = 1'b0;  // tying LDAC low means the output registers on the chip will update on the rising edge of CS
	// end Latch DAC output	
	
	/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	// State machine 
	always @ (posedge clk)
		begin 
			case (STATE)
				
				IDLE :  // doesnt do anything untill the Tx goes high again
					begin  
						CS <= 1;            // disable chip
						MOSI <= 0;          // no data on the MOSI line
						SCK_count_EN <= 0;  // disable SCK
						CC <= 0;            // conversion is complete (always true except for initialization when no conversion has taken place
						
						if (Tx)
							STATE <= SEND;
						else
							STATE <= IDLE;
					end  // IDLE
					
				SEND :  // serializes and send data to DAC
					begin
						CS <= 0;
						DATA_concat <= {i_DATA[0],i_DATA[1],i_DATA[2],i_DATA[3],i_DATA[4],i_DATA[5],i_DATA[6],i_DATA[7],i_DATA[8],i_DATA[9],i_DATA[10],i_DATA[11],SHDN,GA,BUF,AB};  // concatenate the setup data and the input conversion data
						MOSI <= AB;                                    // send channel config bit first
						SCK_count_EN <= 1;                             // enable SPI clk
						CC <= 0;                                       // conversion has not taken place yet
						
						for (i = 0; i < 16 ; i = i + 1)
							begin 
								if (conversion_count < (i + 1)*124 && conversion_count >= i*124 && Tx)
									MOSI <= DATA_concat[i];
							end  // for 
							
						if (conversion_count >= 1984 && conversion_count <= 2498 && Tx)  // after all data conversion complete
							begin 
								MOSI <= 0;
								SCK_count_EN <= 0;  // disable SPI clk
								CC <= 1;            // conversion complete flag goes high
								CS <= 1;
							end  // if (conversion...
						if (conversion_count == 2498)
							STATE <= IDLE;		
					end  // SEND
					
				default : STATE <= IDLE; 
				
			endcase
		end
endmodule
