psect ssd1306Code, class=CODE, reloc=2
#include "i2c.asm"
;;=======================================
;; SSD1306 Sequences ::
;;=======================================
#define SSD1306_BLACK 0   ///< Draw 'off' pixels
#define SSD1306_WHITE 1   ///< Draw 'on' pixels
#define SSD1306_INVERSE 2 ///< Invert pixels

#define SSD1306_MEMORYMODE 0x20          ///< See datasheet
#define SSD1306_COLUMNADDR 0x21          ///< See datasheet
#define SSD1306_PAGEADDR 0x22            ///< See datasheet
#define SSD1306_SETCONTRAST 0x81         ///< See datasheet
#define SSD1306_CHARGEPUMP 0x8D          ///< See datasheet
#define SSD1306_SEGREMAP 0xA0            ///< See datasheet
#define SSD1306_DISPLAYALLON_RESUME 0xA4 ///< See datasheet
#define SSD1306_DISPLAYALLON 0xA5        ///< Not currently used
#define SSD1306_NORMALDISPLAY 0xA6       ///< See datasheet
#define SSD1306_INVERTDISPLAY 0xA7       ///< See datasheet
#define SSD1306_SETMULTIPLEX 0xA8        ///< See datasheet
#define SSD1306_DISPLAYOFF 0xAE          ///< See datasheet
#define SSD1306_DISPLAYON 0xAF           ///< See datasheet
#define SSD1306_COMSCANINC 0xC0          ///< Not currently used
#define SSD1306_COMSCANDEC 0xC8          ///< See datasheet
#define SSD1306_SETDISPLAYOFFSET 0xD3    ///< See datasheet
#define SSD1306_SETDISPLAYCLOCKDIV 0xD5  ///< See datasheet
#define SSD1306_SETPRECHARGE 0xD9        ///< See datasheet
#define SSD1306_SETCOMPINS 0xDA          ///< See datasheet
#define SSD1306_SETVCOMDETECT 0xDB       ///< See datasheet

#define SSD1306_SETLOWCOLUMN 0x00  ///< Not currently used
#define SSD1306_SETHIGHCOLUMN 0x10 ///< Not currently used
#define SSD1306_SETSTARTLINE 0x40  ///< See datasheet

#define SSD1306_EXTERNALVCC 0x01  ///< External display voltage source
#define SSD1306_SWITCHCAPVCC 0x02 ///< Gen. display voltage from 3.3V

#define SSD1306_RIGHT_HORIZONTAL_SCROLL 0x26              ///< Init rt scroll
#define SSD1306_LEFT_HORIZONTAL_SCROLL 0x27               ///< Init left scroll
#define SSD1306_VERTICAL_AND_RIGHT_HORIZONTAL_SCROLL 0x29 ///< Init diag scroll
#define SSD1306_VERTICAL_AND_LEFT_HORIZONTAL_SCROLL 0x2A  ///< Init diag scroll
#define SSD1306_DEACTIVATE_SCROLL 0x2E                    ///< Stop scroll
#define SSD1306_ACTIVATE_SCROLL 0x2F                      ///< Start scroll
#define SSD1306_SET_VERTICAL_SCROLL_AREA 0xA3             ///< Set scroll range

// Deprecated size stuff for backwards compatibility with old sketches
#if defined SSD1306_128_64
#define SSD1306_LCDWIDTH 128 ///< DEPRECATED: width w/SSD1306_128_64 defined
#define SSD1306_LCDHEIGHT 64 ///< DEPRECATED: height w/SSD1306_128_64 defined
#endif
#if defined SSD1306_128_32
#define SSD1306_LCDWIDTH 128 ///< DEPRECATED: width w/SSD1306_128_32 defined
#define SSD1306_LCDHEIGHT 32 ///< DEPRECATED: height w/SSD1306_128_32 defined
#endif
#if defined SSD1306_96_16
#define SSD1306_LCDWIDTH 96  ///< DEPRECATED: width w/SSD1306_96_16 defined
#define SSD1306_LCDHEIGHT 16 ///< DEPRECATED: height w/SSD1306_96_16 defined
#endif
 
OLED_ADDRESS equ 0x3C
OLED_COMMAND equ 0x00
OLED_DATA equ 0x40 

; OLED MACRO ::    
oled_write macro seq
 movlw seq
 call i2c_write
endm
 
ssd1306_init:        
;=======================================
; start I2C & send OLED address (0x3C) 
;=======================================
    call i2c_start
    oled_write OLED_ADDRESS
;=======================================
;  SSD1306 Sequences 
;=======================================
;; PROGMEM init1 ::
    oled_write SSD1306_DISPLAYOFF         ; 1. Display off   
    oled_write SSD1306_SETDISPLAYCLOCKDIV ; 2. Set Clock divide ratio (0x00=1) and oscillator frequency (0x8)       
    oled_write 0x80                       ; suggested ratio        
    oled_write SSD1306_SETMULTIPLEX       ; 3. multiplex ratio
;; PROGMEM init2 ::
    oled_write SSD1306_SETDISPLAYOFFSET   ; 4. display offset 
    oled_write 0x00
    oled_write SSD1306_SETSTARTLINE | 0x0
    oled_write SSD1306_CHARGEPUMP         ; 6. charge pump setting (p62): 0x014 enable, 0x010 disable, SSD1306 only, should be removed for SH1106 */
;; VCC MODE ::
    oled_write SSD1306_SWITCHCAPVCC       ; 0x01 for EXT & 0x02 for SWC
;; PROGMENT init3 ::
    oled_write SSD1306_MEMORYMODE         ; 0x20 - Memory Address Mode: horizontal 
    oled_write 0x00                       ; 0x0 act like ks0108
    oled_write SSD1306_SEGREMAP | 0x1
    oled_write SSD1306_COMSCANDEC    
;; SET COM PINS
;   comPins = 0x02;
;   contrast = 0x8F;
;   128x32
;     comPins = 0x02;
;     contrast = 0x8F;
;   128x64
;     comPins = 0x12;
;     contrast = SSD1306_EXTERNALVCC ? 0x9F : 0xCF;
;   96x16
;     comPins = 0x2; // ada x12
;     contrast = SSD1306_EXTERNALVCC ? 0x10 : 0xAF;
    oled_write SSD1306_SETCOMPINS
    oled_write 0x12                   ; 0x12 - 128x64 | 0x02 - 128x32 | 0x2 - 96x16
    oled_write SSD1306_SETCONTRAST    ; set contrast control
    oled_write 0xCF                   ; 0x9F for EXT_VCC
    oled_write SSD1306_SETPRECHARGE   ;
    oled_write 0xF1                   ; 0x22 for EXT_VCC
;; PROGMEM INIT5 ::
    oled_write SSD1306_SETVCOMDETECT  ; 0xDB
    oled_write 0x40                   ;
    oled_write SSD1306_DISPLAYALLON_RESUME ; 0xA4
    oled_write SSD1306_NORMALDISPLAY       ; 0xA6
    oled_write SSD1306_DEACTIVATE_SCROLL
    oled_write SSD1306_DISPLAYON
;; STOP I2C ;; 
    call i2c_stop
    return

ssd1306_command macro cmd
 call i2c_start
 oled_write OLED_ADDRESS
 oled_write OLED_COMMAND
 oled_write cmd
 call i2c_stop
endm
 
;  ssd1306_command(SSD1306_COLUMNADDR);
;  ssd1306_command(0);    // Column start address
;  #if defined SSD1306_128_64 || defined SSD1306_128_32
;  ssd1306_command(127);  // Column end address
;  #else
;    ssd1306_command(95); // Column end address
;  #endif
;
;  ssd1306_command(SSD1306_PAGEADDR);
;  ssd1306_command(0);   // Page start address (0 = reset)
;  #if defined SSD1306_128_64
;  ssd1306_command(7);   // Page end address
;  #elif defined SSD1306_128_32
;  ssd1306_command(3);   // Page end address
;  #elif defined SSD1306_96_16
;  ssd1306_command(1);   // Page end address
;  #endif
;
;  I2C_Begin();
;  I2C_Write(_i2caddr);
;  I2C_Write(0x40);
;
;  for(uint16_t i = 0; i < SSD1306_LCDHEIGHT * SSD1306_LCDWIDTH / 8; i++ )
;    I2C_Write(0);
;
;  I2C_End();
clear_display macro
    ssd1306_command SSD1306_COLUMNADDR; [0..127]
    ssd1306_command 0x00            ;; column start address 0
    ssd1306_command 127             ;; column end   address 127
    
    ssd1306_command SSD1306_PAGEADDR;; [0..7]
    ssd1306_command 0x00            ;; page start address 0
    ssd1306_command 7               ;; page end   address 7
    
    call i2c_start
    oled_write OLED_ADDRESS
    oled_write OLED_DATA
    
    
column_loop:   
    oled_write 1    ; filling instead of clearing :)
    incf column, f
    movf column, w
    subwf 128
    btfss STATUS, Z
    goto column_loop
    
page_loop:
    incf page, f
    movf page, w
    sublw 8
    btfss STATUS, Z
    goto page_loop
 
fill_buffer:
    call i2c_stop
endm
    
psect udata
page: ds 1
column: ds 1


