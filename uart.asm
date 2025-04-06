; ================================================================
; NOTE:
; * 2 most important things in working with MCU are :
; - Clock Frequency : that was configured for MCU.
; - Data Rate Speed : always set based on MCU clock.
;
; In this UART case, making either of them wrong will result
; in not receiving anything at all. Especially when Baud-Rate
; doesn't match with host/slave.
; ================================================================    
#include <xc.inc>
; define PSECT everytime we need new code block :
psect uartCode, class=CODE, reloc=2
uart_init:
    clrf TRISC    ; Enable RC6/RC7:
    bsf LATC, 6   ; RC6 | TX1
    bsf LATC, 7   ; RC7 | RX1
    
    ;BAUDCON1 = 0x40 = 0100 000
    bsf BAUDCON1, 6; RCIDL = 1 
                   ; Mean: don't IDLE when not receiving anything.
                   
    ; Enable UART by SPEN :
    ; RCSTA1 = 0x80 = 1000 0000
    bsf RCSTA1, 7  ; SPEN = 1 
    
    ; TXSTA1 = 0x26 = 0010 0110
    bsf TXSTA1, 5  ; TXEN : TX is ready(1).
    bsf TXSTA1, 2  ; BRGH : TX is ready(2).
    bsf TXSTA1, 1  ; TRMT : TX is done.
    
    ; Set baud-rate with SPBRG1 :
    ; = 16,000,000 / (16 x 9,600) - 1 = 103.1667 => 103
    ; = 16,000,000 / (16 x 115,200) - 1 = 7.6805 => 8
;    movlw 103     ; 9600 @ 16Mhz FOSC
    movlw 8        ; 115200 @ 16Mhz FOSC
    movwf SPBRG1  ;
    
    clrf SPBRGH1   ; 0x00
    return

uart_enable:
    ; To enable serial com (RX/TX) :
    bsf RCSTA1, 7 ; SPEN = 1 
    return
    
uart_disable:
    ; To disable serial com (RX/TX) :
    bcf RCSTA1, 7 ; SPEN = 0
    return
    
uart_write:
uart_tx_ready:      ; when PIR1.TXIF && TXTSA1.TXEN
    btfss PIR1,   4 ; PIR1.TXIF == 1 ?
    goto uart_tx_ready
    btfss TXSTA1, 5 ; TXTSA1.TXEN == 1 ?
    goto uart_tx_ready
    
uart_send_byte:
    movwf TXREG1      ; TXREG1 = a byte to write
uart_is_tx_done:
    btfss TXSTA1, 1   ; TRMT = 1 ? Tx is done.
    goto uart_is_tx_done
    return
    
uart_deinit:
    clrf BAUDCON1
    clrf RCSTA1
    clrf TXSTA1
    clrf SPBRG1
    clrf SPBRGH1
    return
    
    
 
    
    
