;
; Prelab.asm
;
; Created: 3/02/2025 15:49:40
; Author : Gabriela
; ***************************************************************************************
; Universidad del Valle de Guatemala
; IE2023: Programación de Microcontroladores
; Prelab1.asm

; Autor: Paola Gabriela Yoc Moreira
; Proyecto: Prelab 1
; Hardware: ATMega328P
; Creado: 03/02/2025
; Descripción: 
; ********************************************************************************************

; MCU: ATmega328P
; Botón PD2 -> Incrementar
; Botón PD3 -> Decrementar
; Salida en PORTB (PB0-PB3) 
;************************************************************************************+
;ENCABEZADO
;************************************************************************************
.include "M328PDEF.inc"

.cseg
.org 0x0000
;***********************************************************
; STACK POINTED
;*************************************************************
    ; Configuración de la pila
    LDI R16, LOW(RAMEND)
    OUT SPL, R16
    LDI R16, HIGH(RAMEND)
    OUT SPH, R16
;**************************************************************
; CONFIGURACION
;**************************************************************
    ; Configuración de puertos
SETUP:
    LDI R16, 0x00
    OUT DDRD, R16          ; Configurar PORTD como entrada (botones)
    LDI R16, 0xFF
    OUT PORTD, R16         ; Habilitar pull-ups en PORTD

    LDI R16, 0x0F
    OUT DDRB, R16          ; Configurar PB0-PB3 como salida (contador)
    LDI R17, 0x00          ; Inicializar contador en 0
    OUT PORTB, R17         ; Mostrar el contador en LEDs
;*******************************************************************
; LOOP INFINITO
;****************************************************************
LOOP:
    IN R16, PIND           ; Leer estado de botones
    MOV R18, R16           ; Guardar estado actual para comparación
    
    ; Chequear botón de incremento (PD2 = 0 cuando presionado)
    SBRS R16, 2
    CALL BTN_UP
    
    ; Chequear botón de decremento (PD3 = 0 cuando presionado)
    SBRS R16, 3
    CALL BTN_DOWN

    RJMP LOOP              ; Repetir ciclo

;*********************************************
; Subrutina: Botón de incremento
;*********************************************
BTN_UP:
    CALL ANTI
    IN R16, PIND           ; Leer botón nuevamente después del debounce
    SBRS R16, 2            ; Si sigue presionado, incrementar
    RJMP INC_COUNTER
    RET

INC_COUNTER:
    INC R17                ; Incrementar contador
    CPI R17, 16            ; Si llega a 16, reiniciar a 0
    BRNE NO_RESET_INC
    LDI R17, 0x00
NO_RESET_INC:
    OUT PORTB, R17         ; Mostrar en LEDs
    RET

;*********************************************
; Subrutina: Botón de decremento
;*********************************************
BTN_DOWN:
    CALL ANTI
    IN R16, PIND           ; Leer botón nuevamente después del debounce
    SBRS R16, 3            ; Si sigue presionado, decrementar
    RJMP DEC_COUNTER
    RET

DEC_COUNTER:
    DEC R17                ; Decrementar contador
    BRPL NO_RESET_DEC      ; Si no es negativo, continuar
    LDI R17, 0x0F          ; Si era 0, volver a 15
NO_RESET_DEC:
    OUT PORTB, R17         ; Mostrar en LEDs
    RET

;*********************************************
; Subrutina: Antirrebote
;*********************************************
ANTI:
    CALL DELAY
    IN R16, PIND           ; Leer el puerto D después del retraso
    CP R16, R18            ; Comparar con la primera lectura
    BREQ ANTI_END      ; Si es igual, botón estable
    RJMP ANTI          ; Si cambió, repetir
ANTI_END:
    RET

;*********************************************
; Subrutina: Retardo 
;*********************************************
DELAY:
    LDI R19, 50            ; Número arbitrario para ajustar el retardo
DELAY_LOOP:
    DEC R19
    BRNE DELAY_LOOP
    RET

