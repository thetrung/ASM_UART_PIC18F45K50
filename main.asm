#include "config.inc"
#include "uart.asm"
    
psect resetVector, class=CODE, reloc=2
    goto main

psect mainCode, class=CODE, reloc=2 
main:
    ; Set internal OSC => 16Mhz with IRCF:
    movlw 0b01110000 ; IRCF = 111
    movwf OSCCON     ; OSCCON.IRCF = 7 
    
    ; Start UART :
    call uart_init
    call uart_enable
    
loop:
    movlw 'A' ; == ''
    call uart_write
    
printf_done:
    return