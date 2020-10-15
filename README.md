# SPI-master-for-MCP3202-ADC

ADC
This is a custom serial peripheral interface for a 12 bit ADC (MCP3202)
Datasheet for ADC is here: http://ww1.microchip.com/downloads/en/devicedoc/21034d.pdf

also here is the EDAplayground link for version 1.0 (I think the sample frequency is around 39 KHz):
https://www.edaplayground.com/x/3sLe

Please watch my youtube video on version 1 for more clarification: https://www.youtube.com/watch?v=upVfMuauNak&t=406s

In Version 2.0 I updated the sampling frequency to its max 50 KHz, and changed some timing
on the data valid signal, as well as some of the parameters. 

I also included the zip file in /V2.0 that contains the module in an IP core than can be added to a block design in Vivado
    
DAC
SPI interface for 12 bit DAC MCP4822 outputting 50 Ksps
    
edaplayground link https://www.edaplayground.com/x/eptz

:) happy interfacing!
