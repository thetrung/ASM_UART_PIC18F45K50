#include <xc.inc>
#define FOSC 16000000    ;; Hz
#define I2C_SPEED 100000 ;; Hz
#define SSPADD_VAL (FOSC / (4 * I2C_SPEED)) - 1
;; SSP1STAT
#define SMP 7
#define CKE 6
#define BF 0
;; SSP1CON1
#define SSPEN 5
; SSP1CON2
#define SEN 0
#define PEN 2
#define RCEN 3
#define ACKEN 4
#define ACKDT 5
#define ACKSTAT 6
; PIE1
#define SSPAIE 3
; PIE2
#define BCL1IE 3
; STATUS
#define C 0

psect i2cCode, class=CODE, reloc=2
i2c_init:
    ; Config bits ::
    bsf SSP1STAT, SMP    ; SMP = 1 (but 0x80 in XC8/MCC ?)
    bcf SSP1STAT, CKE    ; CKE = 0
    clrf SSP1CON1        ; 0000 0000
    clrf SSP1CON2        ; 0000 0000
    movlw 39             ; (16.000.000 / (4 x 100.000)) - 1
    movwf SSP1ADD        ; I2C Speed.
    bsf SSP1CON1, SSPEN  ; SSPEN = 1
    bsf SSP1CON1, 3      ; SSPM = 1000 (I2C Master Mode: 0x08=1000)
;    call i2c_isr_disable  ; Interupt Enabled.
    ; Done.
    return

i2c_isr_enable:
    bsf PIE2, BCL1IE   ; BCL1IE = 1
    bsf PIE1, SSPAIE   ; SSPAIE = 1
    return
    
i2c_isr_disable:
    bcf PIE2, BCL1IE    ; BCL1IE = 0
    bcf PIE1, SSPAIE   ; SSPAIE = 0
    return
    
i2c_start:              ; Start-ENable bit ::
    bsf SSP1CON2, SEN   ; SEN = 1
i2c_start_wait:
    btfsc SSP1CON2, SEN ; SEN = 0 ?
    goto i2c_start_wait ; PIR2.BCLIF = 1 : Bus Collision ISR Flag bit
    return              ; NOTE: only work if SSPM = 1000, else it will hang forever.

i2c_stop:
    bsf SSP1CON2, PEN   ; PEN = 1
i2c_stop_wait:
    btfsc SSP1CON2, PEN ; PEN = 1
    goto i2c_stop_wait
    return

i2c_write:              ; Write A byte :
    movwf SSP1BUF       ; W >> SSP1BUF
i2c_write_wait:
    btfsc SSP1STAT, BF  ; Buffer Empty ?
    goto i2c_write_wait ; waiting...
    
    btfsc SSP1CON2, ACKSTAT ; ACK yet ? ACKSTAT == 0 ?
    goto i2c_write_NACK     ; NACK if not ACKed
    return
i2c_write_NACK:         ; ERROR :
    goto i2c_write_wait ; Loop again
    return

i2c_read:
    bsf SSP1CON2, RCEN  ; RCEN = 1
i2c_read_wait:
    btfss SSP1STAT, BF  ; Buffer empty ?
    goto i2c_read_wait
    movf SSP1BUF, w     ; Content >> W
    return
    
i2c_ack:
    bcf SSP1CON2, ACKDT
    bcf SSP1CON2, ACKEN
i2c_ack_wait:
    btfsc SSP1CON2, ACKEN
    goto i2c_ack_wait
    return
    
i2c_nack:
    bsf SSP1CON2, ACKDT
    bsf SSP1CON2, ACKEN
i2c_nack_wait:
    btfsc SSP1CON2, ACKEN
    goto i2c_nack_wait
    return
