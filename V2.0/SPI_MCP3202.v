`timescale 1ns / 1ps

/////////////////////////////////////////////////////////////////////////////////////////
//
//   PROJECT DESCRIPTION:	A SPI master for a MCP3202 12-bit ADC. The sampling frequency
// 							is 50 KHz, making the Nyquist frequency 25 KHz. When the
//                          output 12-bit word is valid, the data valid flag goes high.
//
//	            FILENAME:   SPI_MCP3202.v
//	             VERSION:   2.0  9/17/2020
//                AUTHOR:   Dominic Meads
//
/////////////////////////////////////////////////////////////////////////////////////////


`timescale 1ns / 1ns

module SPI_state_machine #(parameter // set up bits for MOSI (DIN on datasheet) 
	START = 1,      // start bit
	SGL = 1,        // sets ADC to single ended mode
	ODD = 0,        // sets sample input to channel 1
	MSBF = 1        // sets ADC to transmit MSB first
	)(
	input clk,                 // 125  MHz 
	input MISO,                // data out of ADC (Dout pin)
	output MOSI,               // Data into ADC (Din pin)
	output SCK, 	           // SPI clock
	output [11:0] o_DATA,      // 12 bit word (for other modules)
	output CS,                 // Chip Select
	output DATA_VALID          // is high when there is a full 12 bit word. 
	);
	
	// states
	localparam INITIALIZE = 0;      // initialize the state machine
	localparam DISABLE = 1;         // CS is high
	localparam TRANSMITTING = 2;    // set the sample channel, sampling mode, etc...
	localparam RECEIVING = 3;       // convert the bitstream into parellel word
	
	reg [7:0] SCK_counter = 0;       // for the output SPI clock
	reg r_MOSI = 0; 
	reg [11:0] r_DATA;
	reg [1:0] r_STATE;               // state machine
	reg r_CS = 1;       	         // disable CS to start
	reg r_SCK_enable = 0;            // enable for SCK
	reg r_DV = 0;                    // DATA_VALID register
	reg [11:0] sample_counter = 1;   // this counter flips over after one sample period
	                                      // it starts at one so INITIALIZE waits one sampling period to begin DISABLE
	 
	// sample_counter
	always @ (posedge clk)                       
		begin 
			if (sample_counter <= 2498)           /* this number is the amount of system clock cycles to finish one sampling period: 
													 2500 counts (0-2499) @ 8ns system clock period = 20us or 50 KHz */
				begin 
					sample_counter <= sample_counter + 1;
				end 
			else 
				begin 
					sample_counter <= 0;
				end 
		end   // end sample_counter
		
	// SPI_CLK
	always @ (posedge clk)
		begin 
			if (r_SCK_enable == 1 && SCK_counter <= 138)              /* 140 counts (0-139) @ 8ns system clock period 
													                     is 893 KHz, < SCK max frequency of 0.9 MHz (datasheet) */
				begin 
					SCK_counter <= SCK_counter + 1;
				end 
			else 
				begin 
					SCK_counter <= 0;
				end 
		end                                                             	
	assign SCK = (SCK_counter <= 69) ? 0:1;      // 50% duty cycle PWM/SPI clock   
		
	// State machine	
	always @ (posedge clk)
		begin 
			case (r_STATE)
				
				
				INITIALIZE:                //this just makes the whole process wait a bit (more for simulation purposes due to clk initialization)
					begin 
						r_CS <= 1;
						r_SCK_enable <= 0;
						r_MOSI <= 0;
						r_DV <= 0;
							if (sample_counter == 2499)    // makes INITIALIZE wait a whole sampling period for set up 
								begin 
									r_STATE <= DISABLE;
								end
							else 
								begin 
									r_STATE <= INITIALIZE;
								end
					end   // end INITIALIZE	
				
				
				DISABLE:              
					begin 
						r_CS <= 1;
						r_SCK_enable <= 0;
						r_MOSI <= 0;
						r_DV <= 0;
							if (sample_counter == 63)     // ensures that DISABLE waits 64 counts or 512ns (tcsh must >= 500ns in datasheet)
								begin 
									r_STATE <= TRANSMITTING;
									r_CS <= 0;                       // CS pulled low, activates sampling
						            r_MOSI <= START;
								end
							else
								begin 
									r_STATE <= DISABLE;
								end
					end     // end DISABLE 
					
					
				TRANSMITTING:
					begin 
						r_CS <= 0;                       // CS pulled low, activates sampling
						r_SCK_enable <= 0;
						r_MOSI <= START;
						r_DV <= 0;
							if (sample_counter >= 119)     
								begin 
									r_SCK_enable <= 1;   // pull SCK high after 56 counts @ 8ns (448ns, check tsucs in datasheet, tsucs >= 100ns)
								end 
							if (sample_counter >= 190 && sample_counter < 330)
								begin 
									r_MOSI <= SGL;        // provides set up data to ADC depending on the timing
								end
							else if (sample_counter >= 330 && sample_counter < 470)
								begin 
									r_MOSI <= ODD;
								end
							else if (sample_counter >= 470 && sample_counter < 610)
								begin 
									r_MOSI <= MSBF;
								end
							else if (sample_counter == 610 && r_MOSI == MSBF)
								begin 
									r_STATE <= RECEIVING;
								end
							else 
								begin 
									r_STATE <= TRANSMITTING;
								end
					end    // end TRANSMITTING
					
					
				RECEIVING: 
					begin 
						r_CS <= 0;                       
						r_SCK_enable <= 1;
						r_MOSI <= 0; 						// MOSI is "don't care" in this state
							if (sample_counter == 785)      // waits 1.5 SCK cycle after MSBF bit because MISO transmitts null bit (MUST SAMPLE AT MIDPOINT OF BIT)
								begin 
									r_DATA[11] <= MISO;
									r_DV <= 0;
								end
							if (sample_counter == 925)
								begin 
									r_DATA[10] <= MISO;
									r_DV <= 0;
								end 
							if (sample_counter == 1065)
								begin 
									r_DATA[9] <= MISO;
									r_DV <= 0;
								end 
							if (sample_counter == 1205)
								begin 
									r_DATA[8] <= MISO;
									r_DV <= 0;
								end 
							if (sample_counter == 1345)
								begin 
									r_DATA[7] <= MISO;									
									r_DV <= 0;
								end 
							if (sample_counter == 1485)
								begin 
									r_DATA[6] <= MISO;
									r_DV <= 0;
								end 
							if (sample_counter == 1625)
								begin 
									r_DATA[5] <= MISO;
									r_DV <= 0;
								end 
							if (sample_counter == 1765)
								begin 
									r_DATA[4] <= MISO;
									r_DV <= 0;
								end 
							if (sample_counter == 1905)
								begin 
									r_DATA[3] <= MISO;
									r_DV <= 0;
								end 
							if (sample_counter == 2045)
								begin 
									r_DATA[2] <= MISO;
									r_DV <= 0;
								end 
							if (sample_counter == 2185)
								begin 
									r_DATA[1] <= MISO;
									r_DV <= 0;
								end 
							if (sample_counter == 2325)
								begin 
									r_DATA[0] <= MISO;
									r_DV <= 0;                     
								end 
							if (sample_counter == 2345)
								begin 
									r_DV <= 1;                     // Data is now valid
								end 	
							if (sample_counter == 0)               // After counter flips over, the sample is over, and it is time for another one
								begin 
									r_STATE <= DISABLE;
								end 
							else 
								begin 
									r_STATE <= RECEIVING;
								end 
					end // end RECEIVING	
								
						
					
					
				default: 
					begin 
						r_STATE <= INITIALIZE;
					end 
					
					
			endcase
		end	
	
	assign CS = r_CS;                  // output signals
	assign MOSI = r_MOSI;
	assign o_DATA = r_DATA;
	assign DATA_VALID = r_DV; 
		
endmodule 		
				
			
