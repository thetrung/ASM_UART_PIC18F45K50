#include <xc.inc>
psect i2cCode, class=CODE, reloc=2
;===================================================
; CONSTANTS
;===================================================    
#define FOSC 16000000    ;; Hz
#define I2C_SPEED 100000 ;; Hz
#define SSPADD_VAL (FOSC / (4 * I2C_SPEED)) - 1
;; SSP1STAT
#define SMP 7
#define CKE 6
#define BF 0
#define R_nW 2
;; SSP1CON1
#define SSPEN 5
; SSP1CON2
#define SEN 0
#define PEN 2
#define RCEN 3
#define ACKEN 4
#define ACKDT 5
#define ACKSTAT 6
; PIE2
#define BCL1IE 3
; PIE1
#define SSPAIE 3
; STATUS
#define C 0
#define Z 2

mov macro reg, value
 movlw value
 movwf reg
endm
;
;void I2C_Initialize(const unsigned long feq_K) //Begin IIC as master
;{
;//  TRISB0 = 1;  TRISB1 = 1;  //Set SDA and SCL pins as input pins
;  LATB0 = 1;  LATB1 = 1;  //Set SDA and SCL pins as input pins
;
;  SSP1CON1  = 0b00101000;    //pg84/234
;  SSP1CON2 = 0b00000000;    //pg85/234
;
;  SSP1ADD = (_XTAL_FREQ/(4*feq_K*100))-1; //Setting Clock Speed pg99/234
;  SSP1STAT = 0b00000000;    //pg83/234
;}
i2c_init:
    ; Config bits ::
    bcf LATB, 1     ; 34/RB1 | SCL
    bcf LATB, 0     ; 33/RB0 | SDA  
    mov SSP1STAT, 0x80 ; 1000 0000 (SMP = 1)
    mov SSP1CON1, 0x08 ; 0000 1000 (SSPM = 1000)
    mov SSP1CON2, 0x00 ; 0000 0000
    mov SSP1ADD, 0x27  ; (16.000.000 / (4 x 100.000)) - 1 = 39
    bsf SSP1CON1, SSPEN  ; SSPEN = 1
    return
    
;void I2C_Hold()
;{
;    while (   (SSP1CON2 & 0b00011111)    ||    (SSP1STAT & 0b00000100)   ) ; //check the this on registers to make sure the IIC is not in progress
;}
i2c_hold:
    btfsc SSP1STAT, R_nW ; skip loop if R_nW = 0 (clear)  
    goto i2c_hold   
                         ; check SSP1CON2 :
    movf SSP1CON2, w
    andlw 0b00011111     ; hold any busy regs in [0..4]
    btfss STATUS, Z      ; skip loop if STATUS.Z = 1 ( set )
    goto i2c_hold        ; loop if not equal ( busy)
    return
    
;void I2C_Begin()
;{
;  I2C_Hold();  //Hold the program is I2C is busy 
;  SEN = 1;     //Begin IIC pg85/234
;}
i2c_start:             
    call i2c_hold
    bsf SSP1CON2, SEN   ; SEN = 1
    return              

;void I2C_Stop()
;{
;  I2C_Hold(); //Hold the program is I2C is busy 
;  PEN = 1;    //End IIC pg85/234
;}
i2c_stop:
    call i2c_hold
    bsf SSP1CON2, PEN   ; PEN = 1
    return

;void I2C_Write(unsigned data)
;{
;  I2C_Hold(); //Hold the program is I2C is busy
;  SSPBUF = data;         //pg82/234
;}
 
i2c_write:              ; Write A byte :
    call i2c_hold
    movwf SSP1BUF       ; W >> SSP1BUF
    return 