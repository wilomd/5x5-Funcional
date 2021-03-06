
	CBLOCK
	DataOutput
	ENDC
	
;===============================================================================
;			CONFIGURA EL PIC COMO MAESTRO I2C 
;===============================================================================
I2C_INIT_MASTER
	BANK1

	BSF TRISC,3	    ;SDA COMO ENTRADA
	BSF TRISC,4	    ;SCL COMO ENTRADA
	    
	MOVLW 0x09	    ;(FOSC/(4*BAUD_RATE))-1 -> (4000000/(4*100000))-1	
	MOVWF SSPADD	    ;BAUD_RATE 100 Khz para 4Mhz
	
	MOVLW B'10000000'   
	MOVWF SSPSTAT	    ;DESHABILITA CONTROL DE VARIACIONES PARA VELOCIDAD EST�NDAR (100kHz).
	
	CLRF SSPCON2	    ;CONDICIONES INICIALES EN CERO, LLAMADA GENERAL DESHABILITADA
	
	BANK0
	MOVLW B'00101000'   
	MOVWF SSPCON	    ;SELECCIONA Y HABILITA I2C EN MODO MAESTRO
	
	BCF PIR1,SSPIF	    
	BCF PIR1,BCLIF
	
	RETURN
;===============================================================================
;			CONFIGURA EL PIC COMO ESCLAVO I2C 
;===============================================================================
I2C_INIT_SLAVE
	BANK1
	BSF TRISC,3
	BSF TRISC,4
	
	;MOVLW B'11000000'
	MOVWF SSPADD	    ;SE CARGA LA DIRECCI�N DEL ESCLAVO EN W AL HACER EL LLAMADO
	
	MOVLW B'10000000'   ;DESHABILITA CONTROL DE VARIACIONES PARA VELOCIDAD EST�NDAR (100kHz).
	MOVWF SSPSTAT
	
	CLRF SSPCON2	    ;CONDICIONES INICIALES EN CERO, LLAMADA GENERAL DESHABILITADA
	
	BANK0
	MOVLW B'00100110'
	MOVWF SSPCON	    ;SELECCIONA Y HABILITA I2C EN MODO ESCLAVO CON DIRECCI�N DE 7 BITS
	
	BCF PIR1,SSPIF
	BCF PIR1,BCLIF
		
	RETURN
;===============================================================================
;			INICIA LA COMUNICACI�N I2C
;===============================================================================	
I2C_START_MASTER
	BANK0
	BCF PIR1,SSPIF
	BANK1
	BSF SSPCON2,SEN	    ;ENV�A LA CONDICI�N DE INICIO
	BANK0
i2c_start_wait
	BTFSC SSPCON2,SEN   ;TERMIN� DE ESTABLECER LA CONDICI�N DE INICIO?
	GOTO i2c_start_wait
	
	RETURN
;===============================================================================
;			TRANSMITE MENSAJE I2C
;===============================================================================
TX
	BANK0
	BCF PIR1,SSPIF
	
	MOVF DataOutput,W   
	MOVWF SSPBUF		;CARGA MENSAJE PARA SER ENVIADO
	
tx_wait
	BTFSS PIR1,SSPIF	;YA SE ENV�O EL MENSAJE?
	GOTO tx_wait	    
	
	BANK1
	BTFSC SSPCON2,ACKSTAT	;FUE RECONOCIDO EL ESCLAVO?
	GOTO $-1
	
	RETURN

;===============================================================================
;	    ESTABLECE LA CONDICI�N DE PARADA DE LA TRANSMISI�N
;===============================================================================
BSTOP
	BANK0
	BCF PIR1,SSPIF
	BANK1
	BSF SSPCON2,PEN
	BANK0
bstop_wait
	BTFSS PIR1,SSPIF
	GOTO bstop_wait
	
	RETURN

;===============================================================================
;			ENV�A UN BYTE POR EL BUS I2C
;===============================================================================
BYTE_WRITE
	CALL I2C_START_MASTER	;INICIA LA COMUNIACI�N
	BANK0
	MOVWF DataOutput	;DATO CARGADO EN W ANTES DE LLAMAR LA RUTINA
	CALL TX			;TRANSMITE
	BANK0
	RETURN
	
;=============================================================================
TONOERROR
	; GENERA TONO DE ERROR
	; VUELVE A ESPERAR PULZAR TECLAS CORRECTA
;==============================================================================
;Se generan 3 tonos 
;Con 4MHz de frequencia la frecuencia m�nima de PWM es de 244 Hz, que se ubica 
;entre las notas musicales de la octava 4 (ni an graves ni tan agudas)
;PWM en modo Simple Output solo es posible en el pin P1A (RC2)
;==============================================================================
INIT_FRQ
	BANK1
	MOVLW .212 
	MOVWF PR2	    ;CARGA LA FRECUENCIA INICIAL DEL PWM (212 HZ) NOTA RE(4)
	CALL CONFIG_PWM	    ;PARAMETROS PARA EL MODO PWM
	CALL INIT_PWM	    ;INICIA EL PWM
	MOVLW .255	    
	CALL RETARDO_NOTAS_20MS
	MOVLW .224	    
	CALL LOAD_FREQ	    ;NOTA DO#(4)
	MOVLW .255
	CALL RETARDO_NOTAS_20MS   
	MOVLW .238	    
	CALL LOAD_FREQ	    ;NOTA DO(4)
	MOVLW .255
	CALL RETARDO_NOTAS_20MS
	MOVLW .255
	CALL RETARDO_NOTAS_20MS
	CALL DISABLE_PWM
	RETURN
;==============================================================================
;			CONFIGURA EL MODO PWM
;==============================================================================
CONFIG_PWM
	BANK1
	BSF TRISC,2	    ;PONE EL PIN P1A COMO ENTRADA PARA MANTENER NACTIVO EL PWM
	BANK0
	MOVLW B'00111100'   
	MOVWF CCP1CON	    ;MODO PWM CON P1A,P1B,P1C,P1D ACTIVOS EN ALTO
	MOVLW B'00111111'
	MOVWF CCPR1L	    ;DUTY CYCLE AL 25%(?)
	BCF PIR1,TMR2IF	    ;SE LIMPIA BANDERA DEL TIMER2
	MOVLW B'00000011'
	MOVWF T2CON	    ;PREESCALADOR A 16
	RETURN
;==============================================================================
;			INICIA EL PWM
;==============================================================================
INIT_PWM
	BANK1
	BCF TRISC,2	    ;PIN PIA COMO SALIDA PARA EL PWM
	BSF T2CON,TMR2ON    ;SE INICIA EL TIMER
	RETURN
;==============================================================================
;			DESACTIVA EL PWM
;==============================================================================
DISABLE_PWM
	BANK1
	BSF TRISC,2
	RETURN 
;==============================================================================
;		CARGA UN VALOR EN PR2 PARA EL CAMBIO DE FREQ
;==============================================================================
LOAD_FREQ
	BANK1
	MOVWF PR2
	RETURN

RETARDO_NOTAS_20MS
	BANK0
	MOVWF CONTA_2
	MOVLW .250
	MOVWF CONTA_1
	NOP
	DECFSZ CONTA_1,F
	GOTO $-.2
	DECFSZ CONTA_2,F
	GOTO $-.6
	RETURN
;==============================================================================

;==============================================================================	
TONOBUENO
	BANK1
	MOVLW .238 
	MOVWF PR2	    ;CARGA LA FRECUENCIA INICIAL DEL PWM (212 HZ) NOTA DO(4)
	CALL CONFIG_PWM	    ;PARAMETROS PARA EL MODO PWM
	CALL INIT_PWM	    ;INICIA EL PWM
	MOVLW .255	    
	CALL RETARDO_NOTAS_20MS
	MOVLW .212	    
	CALL LOAD_FREQ	    ;NOTA RE (4)
	MOVLW .255
	CALL RETARDO_NOTAS_20MS   
	MOVLW .188	    
	CALL LOAD_FREQ	    ;NOTA MI (4)
	MOVLW .255
	CALL RETARDO_NOTAS_20MS
	MOVLW .150
	CALL RETARDO_NOTAS_20MS
	MOVLW .238	    
	CALL LOAD_FREQ	    ;NOTA DO (4)
	MOVLW .80
	CALL RETARDO_NOTAS_20MS
	MOVLW .188	    
	CALL LOAD_FREQ	    ;NOTA MI(4)
	MOVLW .255
	CALL RETARDO_NOTAS_20MS
	MOVLW .150
	CALL RETARDO_NOTAS_20MS
	CALL DISABLE_PWM
	RETURN
