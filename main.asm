#include "config.inc"
#include "uart.asm"
#include "ssd1306.asm"

psect resetVector, class=CODE, reloc=2
    goto main

psect mainCode, class=CODE, reloc=2    
main:
    ; Set internal OSC => 16Mhz with IRCF:
    movlw 0b01110000 ; IRCF = 111
    movwf OSCCON     ; OSCCON.IRCF = 7 
    call uart_init
    call uart_enable

loop_i2c:
    ; Start I2C     ;
    call print_start
    call i2c_init
    ; Init SSD1306
    call print_i2c
    call ssd1306_init
    call delay_1ms
    draw_pixel 0x04 ;; draw (10,10)
    ; Done.
    call print_done
    ; Restart ?
    goto loop_i2c
    
loop_wait:          ; Loop 4ever
    goto loop_wait
    
    
delay_1ms:
    clrf T1CON
    clrf PIR1
    mov TMR1L, 0x60
    mov TMR1L, 0xD1
    mov T1CON, 0x01
wait_TMR1IF:
    btfss PIR1, 0 ; TMR1IF
    goto wait_TMR1IF
    bcf   PIR1, 0 ; TMR1IF
    return
    
printc macro char
 movlw char
 call uart_write
endm

newline macro
    printc  0x0D; CR
    printc  0x0A; LF
endm

print_i2c:  ;; I2C
    printc  'I'
    printc  '2'
    printc  'C'
    newline
    return
    
print_done:
    ;; I2C
    printc  'D'
    printc  'O'
    printc  'N'
    printc  'E'
    newline
    return
    
    
print_start:
    ;; START
    printc 'S'
    printc 'T'
    printc 'A'
    printc 'R'
    printc 'T'
    newline
    return