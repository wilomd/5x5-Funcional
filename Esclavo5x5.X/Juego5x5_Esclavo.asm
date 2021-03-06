;Programa del pic esclavo I2C
;Se manejan interrupciones I2C
	

;FALTANTE!!!!
	
	;MANEJAR LOS ERRORES EN I2C
	
	LIST   P=PIC16F887
	;List p=16f887
	#include <p16f887.inc>
	;
	
	
	__CONFIG H'2007', H'3FFC' & H'3FF7' & H'3FFF' & H'3FFF' & H'3FFF' & H'3FFF' & H'3CFF' & H'3BFF' & H'37FF' & H'2FFF' & H'3FFF'
	__CONFIG H'2008', H'3EFF' & H'3FFF'	

;===============================================================================
;             Definicion de las macros para cambiar de bancos
;===============================================================================
BANK0	MACRO
	BCF STATUS,5 ;PUERTO DPUERTO D
	BCF STATUS,6
	ENDM
BANK1	MACRO
	BSF STATUS,5
	BCF STATUS,6
	ENDM
BANK2	MACRO
	BCF STATUS,5
	BSF STATUS,6
	ENDM
BANK3	MACRO
	BSF STATUS,5
	BSF STATUS,6
	ENDM
	
ClSPort MACRO
	BANK0
	CLRF PORTC
	CLRF PORTB
	CLRF PORTA
	CLRF PORTD
	CLRF PORTE
	ENDM
	
DigPort MACRO
	BANK3
 	CLRF ANSEL
	CLRF ANSELH
	ENDM	
	
ROTABOM	    EQU  0X20
	    
DATO	    EQU	 0X21	    
DATO1	    EQU  0X22
DATO2	    EQU  0X23
DATO4	    EQU  0X24

CONTA_1	    EQU 0x71
CONTA_2	    EQU 0x72
CONTA_3	    EQU 0x73	 
 
;$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$	
;$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$	
;$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$	
;$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
	
	ORG H'0'
	GOTO INICIO
	
	ORG 0x04
salt	BANK0
	BTFSS PIR1,SSPIF    ;INTERRUPCI�N I2C?
	GOTO END_INT
	BCF PIR1,SSPIF	    ;LIMPIAR FLAG DE INTERRUPCION
;===============================================================================
;             MANEJO DE INTERRUPCI�N I2C COMO ESCLAVO
;===============================================================================
I2C_INT
	BANK1
	BTFSC SSPSTAT,R_W   ;ES LECTURA O ESCRITURA?
	GOTO END_INT
	
	BTFSS SSPSTAT,BF    ;EL BUFFER TIENE DATOS?
	GOTO END_INT	    
	
	BTFSS SSPSTAT,D_A   ;ES DIRECCI�N O DATO?
	GOTO I2C_ADDRESS    ;RUTINA DE LECTURA DE DIRECCI�N
	
	BANK0
	MOVF SSPBUF,W	    ;SE LEE EL DATO
	CALL PROGRAMA

	BANK1
	BCF SSPSTAT,BF	    ; SE LIMPIA BANDERA Y ENV�A ACK
	GOTO END_INT
I2C_ADDRESS
	BANK0
	MOVF SSPBUF,W
END_INT
	;ClSPort
	RETFIE
;===============================================================================
;		Equivalencia numerica de los bombillos	
;=============================================================================== 
BombilloResp
	ADDWF PCL,F
	DT  .0,  .1,  .2,   .3, .4 
	    ;RA0 RA1  RA2  RA3  RA4
	    
	DT  .5,  .6,   .7,  .8, .9 
	    ;RA5 RA6  RA7  RB0  RB1
	    
	DT  .10, .11, .12, .13, .14
	    ;RB2 RB3  RB4  RB5  RB6
	    
	DT .15,  .16, .17, .18, .19
	    ;RB7 RD0  RD1  RD2  RD3
	    
	DT  .20, .21, .22, .23, .24	
	    ;RD4 RD5  RD6  RD7  RE0
END_BombilloResp
;===============================================================================	    
GusanoHrztl
	ADDWF PCL,F    
	DT  .00, .01, .02, .03, .04
	DT  .09, .08, .07, .06, .05
	DT  .10, .11, .12, .13, .14
	DT  .19, .18, .17, .16, .15 
	DT  .20, .21, .22, .23, .24
END_GusanoHrztl
;===============================================================================	
GusanoDiagnl
	ADDWF PCL,F
	DT  .00, .01, .05, .10, .06
	DT  .02, .03, .07, .11, .15
	DT  .20, .16, .12, .08, .04
	DT  .09, .13, .17, .21, .22
	DT  .18, .14, .19, .23, .24
END_GusanoDiagnl
;===============================================================================
GusanoVertcl
	ADDWF PCL,F
	DT  .00, .05, .10, .15, .20
	DT  .01, .06, .11, .16, .21
	DT  .02, .07, .12, .17, .22
	DT  .03, .08, .13, .18, .23
	DT  .04, .09, .14, .19, .24
END_GusanoVertcl	
;===============================================================================
	
SALIDAPTO
	ADDWF PCL,F
	DT  .01, .02, .04, .08, 10H
	DT  20H, 40H, 80H, .01, .02
	DT  .04, .08, 10H, 20H, 40H
	DT  80H, .01, .02, .04, .08
	DT  10H, 20H, 40H, 80H, .01
END_SALIDAPTO

	
;===============================================================================
;             INICIO
;===============================================================================	
INICIO
	DigPort
	BANK1
	CLRF TRISA
	CLRF TRISB
	CLRF TRISD
	CLRF TRISE
	MOVLW B'00011000'    
	MOVWF TRISC
	ClSPort
	
	BANK1
	BSF PIE1,3	    ;HABILITA INTERRUPCIONES I2C
	MOVLW B'11000000'   ;HABILITA INTERRUPCIONES GENERALES
	MOVWF INTCON
	MOVLW B'11000000'   ;DIRECCI�N DEL EESCLAVO I2C
	CALL I2C_INIT_SLAVE
	CALL RETARDO_20MS

repite	
	BSF INTCON,PEIE
	BSF INTCON,GIE
	;call salt
	;
	SLEEP		;SE DESPETARA SOLO AL TENER LA INTERURPCION POR I2C
	goto repite
	
;$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$	
; LECTURA DEL PUERTO A ENCENDER EL BOMBILLO POR RANGOS,  SE SELECCIONA EL PUERTO
; CON ESTOS VALORES [0,..7] Pto A, [8,..15] Pto B, [16..23] Pto D, [24] Pto E
; ESTA FUNCION ES PARA ENCENDER EL ACIERTO Y EL LLAMADO DE ATENCION
;$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$	
PROGRAMA	
	MOVWF DATO     ; CARGA EN DATO EL VALOR DE W
	MOVF  DATO,W	
	SUBLW .07	; SI es menor se ejecuta puerto A     
	BTFSS STATUS,C  ; C = 1 W <= k
	GOTO OTROPTB

	MOVF  DATO,W
	CALL SALIDAPTO 
	ClSPort
	MOVWF PORTA
	CALL cuatoSeg
	RETURN
	
OTROPTB	
	MOVF  DATO,W
	SUBLW .15	; SI es menor se ejecuta puerto B
	BTFSS STATUS,C  ; C = 1 W <= k
	GOTO OTROPTOD
	
	MOVF  DATO,W
	CALL SALIDAPTO 
	ClSPort
	MOVWF PORTB
	CALL cuatoSeg
	RETURN

OTROPTOD
	MOVF  DATO,W
	SUBLW .23	; SI es menor se ejecuta puerto D
	BTFSS STATUS,C  ; C = 1 W <= k
	GOTO OTROPTOE
	
	MOVF  DATO,W
	CALL SALIDAPTO
	ClSPort
	MOVWF PORTD
	CALL cuatoSeg
	RETURN

OTROPTOE
	MOVF  DATO,W
	SUBLW .24	
	BTFSS STATUS,Z  ; Z = 1 W = k
	
	GOTO gusanos
	
	MOVF  DATO,W    ; SI es 24 se ejecuta puerto E
	CALL SALIDAPTO
	ClSPort
	BSF PORTE,0
	CALL cuatoSeg
	
;===============================================================================
gusanos  ;#30, 31, 32
;===============================================================================
	MOVF  DATO,W
	SUBLW 0x30	
	BTFSS STATUS,Z  
	GOTO gusan01
	CALL GUSANO1
	goto next
	
gusan01	
	MOVF  DATO,W
	SUBLW 0x31	
	BTFSS STATUS,Z
	GOTO gusan02
	CALL GUSANO3
	goto next
	
gusan02
	MOVF  DATO,W
	SUBLW 0x32	
	BTFSS STATUS,Z
	GOTO FILA1
	CALL GUSANO5
	goto next
	
FILA1
	MOVF  DATO,W
	SUBLW 0x50	
	BTFSS STATUS,Z  
	GOTO FILA2
	MOVLW B'00011111'
	MOVWF PORTA
	goto next	
FILA2
	MOVF  DATO,W
	SUBLW 0x51	
	BTFSS STATUS,Z  
	GOTO FILA3
	
	MOVLW 0E0H
	MOVWF PORTA
	
	MOVLW B'00000011'
	MOVWF PORTB
	goto next

FILA3
	MOVF  DATO,W
	SUBLW 0x52	
	BTFSS STATUS,Z  
	GOTO FILA4
	MOVLW B'01111100'
	MOVWF PORTB
	goto next
	
FILA4
	MOVF  DATO,W
	SUBLW 0x53	
	BTFSS STATUS,Z  
	GOTO FILA5
	MOVLW B'10000000'
	MOVWF PORTB
	MOVLW B'00001111'
	MOVWF PORTD
	goto next
FILA5
	MOVF  DATO,W
	SUBLW 0x54	
	BTFSS STATUS,Z  
	GOTO next
	MOVLW B'11110000'
	MOVWF PORTD
	MOVLW B'0001'
	MOVWF PORTE
		
next	RETURN	
	
	
;$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$	
GUSANO1
	
	MOVLW	.00
	MOVWF	DATO4
OTRO	MOVF	DATO4,W
	CALL	GusanoHrztl
	CALL	PROGRAMA
	INCF	DATO4,F
	MOVF	DATO4,W
	SUBLW	.25
	BTFSS	STATUS,Z
	GOTO	OTRO
GUSANO2 	
	MOVLW .24 
	MOVWF DATO4
OTRO1	MOVF  DATO4,W
	CALL GusanoHrztl
	CALL PROGRAMA
	DECF DATO4,F
	MOVF DATO4,W
	SUBLW 0xFF
	BTFSS STATUS,Z
	GOTO OTRO1
	ClSPort
	RETURN
;$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$		
GUSANO3
	CLRF DATO4
OTRO2	MOVF  DATO4,W
	CALL GusanoDiagnl
	CALL PROGRAMA
	INCF DATO4,F
	MOVF DATO4,W
	SUBLW .25
	BTFSS STATUS,Z
	GOTO OTRO2
GUSANO4 	
	MOVLW .24 
	MOVWF DATO4
OTRO3	MOVF  DATO4,W
	CALL GusanoDiagnl
	CALL PROGRAMA
	DECF DATO4,F
	MOVF DATO4,W
	SUBLW 0xFF
	BTFSS STATUS,Z
	GOTO OTRO3
	ClSPort
	RETURN
;$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$		
GUSANO5
	CLRF DATO4
OTRO4	MOVF  DATO4,W
	CALL GusanoVertcl
	CALL PROGRAMA
	INCF DATO4,F
	MOVF DATO4,W
	SUBLW .25
	BTFSS STATUS,Z
	GOTO OTRO4
GUSANO6 	
	MOVLW .24 
	MOVWF DATO4
OTRO5	MOVF  DATO4,W
	CALL GusanoVertcl
	CALL PROGRAMA
	DECF DATO4,F
	MOVF DATO4,W
	SUBLW 0xFF
	BTFSS STATUS,Z
	GOTO OTRO5
	ClSPort
	RETURN
;$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$	
RETARDO_20MS
	BANK0
	MOVLW .20
	MOVWF CONTA_2
	MOVLW .250
	MOVWF CONTA_1
	NOP
	DECFSZ CONTA_1,F
	GOTO $-.2
	DECFSZ CONTA_2,F
	GOTO $-.6
	RETURN 
	
;##############################################################################	
cuatoSeg
	
	BANK0
	MOVLW .50
	MOVWF CONTA_3
	CALL RETARDO_20MS
	NOP
	DECFSZ CONTA_3,F
	GOTO $-.3	
	return
;##############################################################################	
	#include "I2C.INC"
	END