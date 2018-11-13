; FORMATO DEL PANEL
;		     0	 1   2   3   4 bits puertoB
;0	A   a	     1,  2,  3,  4,  5	
;1	B   b	     6,  7,  8,  9, 10
;2	C   c	    11, 12, 13, 14, 15
;3	D   d	    16, 17, 18, 19, 20	    
;4	E   e	    21, 22, 23, 24, 25
;puerto c	
	
; 1ra columna Animales solo bombillos 
; 2da Columna Preguntas solo bombillos
; 25 bombillos no manejables en este programa por los momentos
; 25 pulsadores panel de Respuesta del teclado matricial
; 1 Pulsador de inicio del Sistema	
; 1 Salida de Audio para los Tonos (de acierto o respuesta Errada)
; comunicacion con un expansor de puertos o otro pic16f887
; Utilizando los bits 0, 1, 3, 4, 5 para encender los bombillos de los animales
	
;COMO CONECTAR:
; PUERTO A:
	;
	

;$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$	    
	List p=16f887
	#include <p16f887.inc>
	
	__CONFIG H'2007', H'3FFC' & H'3FF7' & H'3FFF' & H'3FFF' & H'3FFF' & H'3FFF' & H'3CFF' & H'3BFF' & H'37FF' & H'2FFF' & H'3FFF'
	__CONFIG H'2008', H'3EFF' & H'3FFF'	
;===============================================================================
	;                VARIABLES DEL PROGRAMA
;===============================================================================	
CONTA_2	    EQU 0x20
CONTA_1	    EQU 0x21
BIT	    EQU 0x22
TECLA	    EQU 0x23
LAST_TECLA  EQU 0x24
RESPUESTA   EQU 0x25
CORRECTO    EQU 0x26
CONT_WIN    EQU 0x27
TEMP0	    EQU	0X28
TEMP1	    EQU	0X29

ANIMALES    EQU 0X30
PREGUNTA    EQU 0X31
TEMP	    EQU 0X32
CONTPRGTA   EQU 0X33	    
PUERTOD	    EQU	0X34
	    
CONTAFIL    EQU	0X35
CONTACOL    EQU	0X36
    
ACTVTKLA    EQU	0X37
    
NVECES	    EQU 0X38
FILNUM	    EQU 0X39
	    
ACTVSW	    EQU 0X40
CONTA_3	    EQU 0X41
PREGTFIL    EQU 0X42	    
temp	    EQU 0X43 
GUSAS	    EQU 0X44
ANIUNO	    EQU 0X45
PREUNO	    EQU 0X46
DATO4	    EQU 0X47	    
;===============================================================================
;			    Definicion de las macros
;===============================================================================
BANK0	MACRO
	BCF STATUS,5
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
	MOVLW 0X04
	MOVWF PORTE
	ENDM
	
DigPort MACRO
	BANK3
 	CLRF ANSEL
	CLRF ANSELH
	ENDM	    
;%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
;%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
;%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
;%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%	    
	ORG H'01'
	CALL CONFIGURA
	GOTO PROGRAM	;INICIA BAJO CONSUMO SLEEP
	
	ORG 04H
	goto ServiceInterrupt
;===============================================================================	    	    
;       inicia el programa en bajo consumo hasta la Interrupcion
;===============================================================================	
PROGRAM
	sleep	    ;Despierta el programa con la Int
	goto PROGRAM			
;===============================================================================
ServiceInterrupt
;===============================================================================	
	btfsc INTCON,RBIF	;change on rb int?
	goto ServiceWakup	;yes then service 
	goto gusanos		; Int por Timer de los 5 Minutos para Gusano
;===============================================================================	
ServiceWakup
;===============================================================================	
	BCF	INTCON,RBIE	;clear mask
	comf	PORTB,W
	BCF	INTCON,RBIF
	andlw	80h		;Mascara para verificar 7 bit en Pto.B
	MOVWF	temp	
	MOVF	temp,w
	BTFSC	temp,7		;Pregunta si se pulso en boton de Inicio Juego
	GOTO	INICIA	
	GOTO    INICIA
;%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
;%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
;%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
;%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%	
		
;===============================================================================	
; 0 1 X X X 5 6 7
ROTACIONPTOC
	ADDWF PCL,F
	DT B'11100010', B'11100001'
	DT B'11000011', B'10100011'
	DT B'01100011'   
END_ROTACIONPTOC	
;===============================================================================		
CONVERT_HEX
	ADDWF PCL,F
	DT  .0,  .1,  .2,  .3,  .4
	DT  .5,  .6,  .7,  .8,  .9
	DT .10, .11, .12, .13, .14
	DT .15, .16, .17, .18, .19
	DT .20, .21, .22, .23, .24
END_CONVERT_HEX
;===============================================================================	
RESPUESTAS_1 
	ADDWF PCL,F
	
; ANIMAL1			
	DT  .4,	 .9,  .14, .19,  .24  ;Probar con estas respuestas solamente
; ANIMAL2
	DT  .0,	 .0,  .0,  .0,  .0
; ANIMAL3	
	DT  .0,	 .0,  .0,  .0,  .0
; ANIMAL4	
	DT  .0,	 .0,  .0,  .0,  .0
; ANIMAL5	
	DT  .0,	 .0,  .0,  .0,  .0
END_RESPUESTAS_1
;===============================================================================
	DT  .0,  .1,  .2,  .3,  .4
	DT  .5,  .6,  .7,  .8,  .9
	DT .10, .11, .12, .13, .14
	DT .15, .16, .17, .18, .19
	DT .20, .21, .22, .23, .24
;==============================================================================	
;==============================================================================
;==============================================================================
;       		inicia el programa	
INICIA
;==============================================================================	
	BANK1
	BCF IOCB,7	    ; SE DESABILITA LA TECLA DE INICIO COMO INT
	BANK0
	BSF PORTE,1
;==============================================================================	
	CALL gusanos
	BANK0
	CALL ENCENDER
SISTPREG
	CALL RETARDO_20MS		;sistema de preguntas y respuestas
	CALL Teclado_LeeOrdenTecla	;ESPERA HASTA QUE SE PULSE UNA TECLA
	CALL RETARDO_20MS		;REPITE HASTA QUE SE PULSE LA TECLA 
					;CORRECTA PARA AVANZAR A LA SIGUIENTE
PROXIMO					;PREGUNTA
	CLRF PORTB				
	CALL VERIFICA1	;SIGUIENTE PREGUNTA Y/O ANIMAL
			;PREGUNTA SI ES EL FINAL DEL CONTADOR DE LAS PREGUNTAS 
			;EN CASO DE NO SER REPITE BUCLE PARA LA PROXIMA PREGUNTA
	GOTO SISTPREG

	;USO DEL PERRO GUARDIAN PARA REINICIAR EL PROGRAMA EN CASO DE FALLA
	
;===============================================================================
;			RUTINAS USADAS EN EL SOFTWARE
;===============================================================================
	    
  
	
	
   
;%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
; esta trabajando cada fila es un animal y las columnas corresponden al valor 	
; numerico de c/u de las 5 respuestas correspondientes del animal, en el ejemplo
; se ve las posiciones de las respuestas de la matriz principal. solo esta primer
; animal con sus 5 posibles respuestas.	
	
	
;%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%	
;		    inicio de las Rutinas (call)
;%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%		


;===============================================================================
; Calcula el OffSet, para calcular el desplazamiento en la matriz de respuesta y
; luego verificar si la respuesta es valida, si es correcta continuara el proceso
; en caso de no ser la respuesta se quedara esperando que sea oprimida la correcta
;debe llevar un contador para que realice este proceso N veces si nadie sigue con
;el juego debe reiniciarse y esperar a ser pulsado el inicio
;===============================================================================
OFFSETR
	MOVF ANIUNO,W	 ; SE DESPLAZARA EN LA TABLA SEGUN ANIMAL Y PREGUNTA
	ADDWF PREUNO,W	 ; Y VERIFICA SI LA TECLA PULSADA ES LA RESPUESTA
	RETURN
			   
			   
;===============================================================================
;	RUTINA DE ENCENDER LA SECUENCIA DE LUCES DE ANIMALES y PREGUNTAS
;       USANDO 5 BITS PUERTO A y D 		    
VERIFICA1   
;===============================================================================
	BCF  STATUS,C
	RLF  PREGUNTA,F	    ; ROTA A LA IZQUIERDA BIT PRENDER BOMBILLO 
	MOVF PREGUNTA,W	    ; INICIA PREGUNTA PARA SABER SI LLEGO AL FIN
	SUBLW 20H	    ; SI EL BIT 5 ESTA ACTIVO REINICIA PROGRAMA
	BTFSS STATUS,Z
	GOTO ENCENDER
	MOVLW .1	    ;inicializa las preguntas para proximo animal
	MOVWF PREGUNTA
;==============================================================================		    
VERIFICA
;==============================================================================	
	BCF  STATUS,C
	RLF  ANIMALES,F	    ; ROTA A LA IZQUIERDA BIT PRENDER BOMBILLO 
	MOVF ANIMALES,W	    ; INICIA PREGUNTA PARA SABER SI LLEGO AL FIN
	SUBLW 20H	    ; SI EL BIT 5 ESTA ACTIVO REINICIA PROGRAMA
	BTFSS STATUS,Z
	GOTO ENCENDER
	MOVLW .1	    ;inicializa las preguntas para proximo animal
	MOVWF ANIMALES
	CALL gusanos
	GOTO KeyRelease
;==============================================================================
ENCENDER
;==============================================================================	
	MOVF	PREGUNTA,W
	MOVWF	PORTD
	CALL PREND_RESPU
	MOVF	ANIMALES,W 
	MOVWF	PORTA
	RETURN
	
PREND_RESPU
	MOVF	PREUNO,W
	ADDLW   50H		    ; se debe sumar 40h al valor de la fila para la rutina
	MOVWF	TECLA       ;SE CARGA EL VALOR DE LA FILA A ENCENDER EN LA MATRIZ
	MOVWF DataOutput
	CALL  ESCLAVO
	CALL  RETARDO_20MS	
	RETURN
	
;==============================================================================
;			LEER EL VALOR EN TECLADO 5x5
; asigna un valor a la tecla pulsada entre 1 y 25 con la tabla CONVERT_HEX
;==============================================================================
READ_HEX
	BTFSS STATUS,C
	GOTO READ_HEX_END
	CALL CONVERT_HEX
	BSF STATUS,C
READ_HEX_END
	RETURN
;==============================================================================	
;===============================================================================
;                      ANTIREBOTE PARA LOS PULSADORES
;===============================================================================
Teclado_EsperaDejePulsar
;	BANK0
;	MOVLW 0x1F
;	MOVWF PORTB
	
Teclado_SigueEsperando
	CALL RETARDO_20MS

	MOVF PORTB,W
	SUBLW 0x1F      

	BTFSS STATUS,Z
	GOTO Teclado_SigueEsperando
	CLRF PORTC
	RETURN
;===============================================================================
; LEE SI SE PULSO UNA TECLAS EN SELECION DE LA RESPUESTA, Y VERIFICA CUAL DE LAS 
;25 TECLAS FUE PULSADA PARA COMPARAR CON SU RESPUESTA.
	
;PENDIENTE;	
;CON EL PUERTO B EN PULL UP AL PRESIONAR EL PULSADOR SE DEBE LEER UNA CERO LOGICO
;===============================================================================
;TECLA	    EQU 0x23
	
Teclado_LeeOrdenTecla      
	BANK0
	CALL PREND_RESPU
	MOVLW .0
	MOVWF TECLA
	MOVWF ACTVSW
	MOVF ACTVTKLA,W	    ; PRIMERA COLUMNA CON CERO PARA MATRIZ DEL TECLADO
			    ; B'11111010' 0FAH VALOR ENVIADO POR LA FILA
			    ; por el pull up se activa con cero logico
CHECK_ROW
	MOVWF PORTC	    ;ENVIA EL VALOR DE W POR EL PUERTO
CHECK_FIL_0
	BTFSS PORTB,0
	GOTO SAVE_VALUE
	INCF TECLA,F
CHECK_FIL_1
	BTFSS PORTB,1
	GOTO SAVE_VALUE
	INCF TECLA,F
CHECK_FIL_2
	BTFSS PORTB,2
	GOTO SAVE_VALUE
	INCF TECLA,F
CHECK_FIL_3
	BTFSS PORTB,3
	GOTO SAVE_VALUE
	INCF TECLA,F
CHECK_FIL_4
	BTFSS PORTB,4
	GOTO SAVE_VALUE
	INCF TECLA,F	
END_FIL
	MOVF	LAST_TECLA,W	; VALOR DE LA VARIABLE ES 25
	SUBWF	TECLA,W		; RESTA 26 MENOS LA TECLA PULSADA
	BTFSC	STATUS,C	; SI X < 25 NO SE PULSO LA ULTIMA TECLA
	GOTO	TECLA_NO_PULSE
	INCF	ACTVSW	
	MOVF	ACTVSW,W
	CALL	ROTACIONPTOC 
	GOTO CHECK_ROW
TECLA_NO_PULSE
	GOTO Teclado_LeeOrdenTecla
;==============================================================================
SAVE_VALUE
	MOVF TECLA,W        ;Variable TECLA contiene el valor pulsado, es el
			    ;valor a encender en los bombillos de respuesta
	MOVWF RESPUESTA	    ;se respalda W en respuesta para operaciones aritmeticas
	CALL ESCLAVO
	call rettkla
	
VALIDATE_ANSWER	
	
	CALL OFFSETR	
	CALL RESPUESTAS_1   ; SE DESPLAZA EN LA TABLA Y SE TRAE EL EN DATO
	SUBWF RESPUESTA	    ;
	BTFSC STATUS,Z
	goto tklbuena	    ;RETORNA SI LA RESPUESTA ES ERRADA y espera la
	GOTO tklmala	    ;correcta x tiempo
			     
  
tklbuena
	INCF  PREUNO,F
	MOVF PREUNO,W
	SUBLW  .5
	BTFSS STATUS,Z
	GOTO SIGCURSO
	CLRF PREUNO
	MOVLW .5
	ADDWF ANIUNO
	
SIGCURSO	
	CLRF  PORTB	 
	CALL TONOBUENO
	MOVF TECLA,W
	CALL ESCLAVO
	call rettkla

	
	return
	
rettkla	
	BANK0		   
	MOVLW .255 ;80
	MOVWF CONTA_3
	CALL RETARDO_20MS
	NOP
	DECFSZ CONTA_3,F
	GOTO $-.3
	RETURN
tklmala
	CALL TONOERROR
	call rettkla

	
	GOTO Teclado_LeeOrdenTecla
	
;===============================================================================	    
;       		inicia parametros para el programa	
CONFIGURA
;===============================================================================	    
	DigPort		    ;inicializa los puertos en digital 
	BANK1
	CLRF TRISA	    ;PUERTO A SALIDA BOMBILLOS ANIMAL
	MOVLW B'10011111'
	MOVWF TRISB	    ;Puerto B ENTRADA PARA EL TECLADO y Boton de inicio
	MOVLW B'00011000'
	MOVWF TRISC
	CLRF TRISD	    ;PUERTO D SALIDA BOMBILLOS PREGUNTA
	CLRF TRISE
	BSF	IOCB,7	
	ClSPort		    ; MACRO DE LIMPIAR LOS PUERTOS
	CALL I2C_INIT_MASTER
	
	BANK0
	MOVLW .1
	MOVWF ANIMALES
	MOVWF PREGUNTA
	MOVWF PUERTOD
	MOVWF CONTAFIL  
	MOVWF CONTACOL
	
	
	MOVLW .25
	MOVWF CONTPRGTA
	MOVWF DataOutput
	
	MOVLW .25
	MOVWF LAST_TECLA
	
	MOVLW 00H
	MOVWF CONT_WIN
	MOVWF ANIUNO	 
	MOVWF PREUNO
	MOVWF GUSAS
	
	MOVLW B'11111010'	;ACTIVA BIT EN CERO PARA ROTAR EN TECLADO
	MOVWF ACTVTKLA
		   ; call rettkla
;==============================================================================	
KeyRelease
;==============================================================================	
	BANK1
	BSF	IOCB,7		    ;ACTIVA INT DE CAMBIO DE ESTADO Bit 7 Puerto B
	BANK0
	CLRF	PORTB
	bcf	INTCON,RBIE	    ;disable mask
	bsf	INTCON,GIE
	movf	PORTB,W		    ;read port
	bcf	INTCON,RBIF	    ;clear flag
	bsf	INTCON,RBIE	    ;enable mask
	retfie		
;===============================================================================
ESCLAVO	
;===============================================================================	
	MOVLW 0xC0		;DIRECCIÓN DEL ESCLAVO A ENVIAR EL DATO
	CALL BYTE_WRITE
	MOVF TECLA,W		;LW 0X30
	CALL BYTE_WRITE
	CALL BSTOP
	RETURN
;===============================================================================
;			    RETARDO DE 20MS
;===============================================================================
RETARDO_20MS
;	RETURN       ; HABILITADO SOLO PARA DEBUG
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
;===============================================================================	
gusanos	
;===============================================================================	
	MOVF GUSAS,W
	SUBLW 00
	BTFSS STATUS,Z
	GOTO GUSA1
	MOVLW 30H
	MOVWF DataOutput
	MOVWF TECLA
	CALL ESCLAVO
	CALL NECESARIO
	GOTO GUSS
GUSA1
	MOVF GUSAS,W
	SUBLW 01
	BTFSS STATUS,Z
	GOTO GUSA2
	MOVLW 31H
	MOVWF DataOutput
	MOVWF TECLA
	CALL ESCLAVO
	CALL NECESARIO
	GOTO GUSS
GUSA2
	MOVF GUSAS,W
	SUBLW 02
	BTFSS STATUS,Z
	GOTO GUSA2
	MOVLW 32H
	MOVWF DataOutput
	MOVWF TECLA
	CALL ESCLAVO
	CALL NECESARIO

GUSS	INCF GUSAS,F
	MOVF GUSAS,W
	SUBLW 03
	BTFSS STATUS,Z
	GOTO ESTO
	CLRF GUSAS
ESTO	RETFIE	
	
	
	
NECESARIO
	call rettkla
	call rettkla
	call rettkla
	call rettkla
	call rettkla
	call rettkla
	call rettkla
	call rettkla
	call rettkla
	call rettkla	
	RETURN
	
;===============================================================================	
	#include "I2C.INC"
;===============================================================================	
	END
	
	
