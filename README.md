UART in PIC Assembly with PIC18F45K50
======================================
It's like sport, I like how simple (& compact) it is when converting into PIC-AS. The nature of bit config manipulation actually fit ASM more than C or any high level language. Also at the time, I can't actually find a readable, easy to understand (& explain) all related concepts/registers involved into a successful UART Serial-COM session ( Up-to-date PIC-AS v3.00 & MPLAB X IDE 6.20+ ).

![IDE](https://github.com/thetrung/ASM_UART_PIC18F45K50/blob/master/ASM_UART.png)

I can say C-equal version of this could be way too "Verbose" and even more confused to understand than this : you basically set coresponding registers to proper-values for features & functionalities. Which actually is the IO-View Table ( or Registers Table ) where configurations are checked per 8 slots ( 8-bit value ). And every state to run the job depends on state (1|0) of a specific register underneath.

Also, even when I have been using various MCU beside Arduino for like, 6 years ago. Using MPLAB to even just for UART is kinda challenging task for terrible & complex workflow they designed. 

### NOTE 
Remember to config 2 things before blame your MCU :
- CPU Clock : should be exactly 16Mhz for Baud-Rate @ 9600.
- Baud Rate : re-check the Data Visualizer since they default speed of this to 115200 with all options pre-checked. For typical UART to test, you just need 2 pins (RX/TX), 8-bit (a byte) per cycle, and 9600 Baud-Rate.

Also, using MCC nowadays may save you sometimes before inventing the wheel again. Still, every C-library for PIC tend to be outdated or require other IDE/Compiler to work with. That meant to isolate people using PIC faster ... Meanwhile Arduino Library is like plug-n-play to relieve the matter.
