.INCLUDE "m328Pdef.inc"

.DEF TMP1 = r16
.DEF TMP2 = r17
.DEF STATE = r18
.DEF LED_PIN = r19
.DEF BUTTON_PIN = r20

.EQU UP = 1
.EQU DOWN = 0

.EQU LED1_PIN = (1 << 4)
; .EQU LED2_PIN = (1 << 5)
; .EQU LED3_PIN = (1 << 6)

.EQU BUTTON1_PIN = (1 << 1)
; .EQU BUTTON2_PIN = (1 << 2)
; .EQU BUTTON3_PIN = (1 << 3)

.MACRO _configure_port
  clr TMP1
  ldi TMP1, LED1_PIN
  out @0, TMP1
.ENDMACRO

.MACRO _set_button
  ldi TMP1, @0
  lsl TMP1
  ori TMP1, 0xFD                   ; STATE[1] & 1111 1101
  or STATE, TMP1
.ENDMACRO 

.MACRO _set_first_output_input
  ldi BUTTON_PIN, BUTTON1_PIN
  ldi LED_PIN, LED1_PIN
.ENDMACRO

.CSEG
rjmp setup

setup:
  _set_button UP                    ;
  _configure_port DDRB
  _configure_port PORTB
  _set_first_output_input
  rjmp loop                         ;

loop:
  lsr BUTTON_PIN
  lsr LED_PIN
  cpi BUTTON_PIN, 1
  brne run_loop
  _set_first_output_input

  run_loop:
    in TMP1, PINB
    and TMP1, BUTTON_PIN
    cpi TMP1, 0
    brne button_pressed

    button_released:
      _set_button UP                    ;
      rjmp loop                         ;

    button_pressed:
      sbrs STATE, 0                     ; if STATE[0] == 0 (is button already down?)
      rjmp loop                         ;

    toggle_led:
      cbr STATE, 1                      ;
      ldi TMP1, 0x2                     ; TMP := 0x2
      eor STATE, TMP1                   ; STATE xor 0x2 (toggle led state bit)
      sbrs STATE, 1                     ; if STATE[1] == 0 (should led be on?)
      rjmp on                           ; STATE[1] == 0 (yes)

      off:
        in TMP1, PORTB
        or TMP1, LED_PIN
        out PORTB, TMP1
        rjmp loop                         ;

      on: 
        in TMP1, PORTB
        eor TMP1, LED_PIN
        out PORTB, TMP1
        rjmp loop                         ;
