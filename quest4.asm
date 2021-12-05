
MCC	EQU	6000H

	ORG	00H
	SJMP	INICIO

	ORG	0BH		;interrupção do timer zero
	CALL	TIMER
	RETI

	ORG	30H
INICIO:	MOV	SP, #2FH
	MOV	IE, #82H	;habilita timer zero
	MOV	TMOD, #21h	;configura temporizador zero no modo 1 e temp1 no modo 2
	MOV	SCON, #40H	;Serial no modo 1
	MOV	TH1, #0FAH	;taxa de 4.800bps
	SETB	TR1		;dispara timer1
	MOV	P1, #1		;INICIA no andar 0
	MOV	R5, #0		;numero do ANDAR

	CALL	M0
	MOV	A, P1
	CALL	DIRETO
	CALL	CRONO
	CJNE	R6, #0, $	;espera o fim do tempo
LDESCE:	JNB	P1.0, DESCE
	INC	R5
LSOBE:	JNB	P1.7, SOBE
	DEC	R5
DESCE:	CALL	INDIRET
	RR	A
	MOV	P1, A
	DEC	R5
	CALL	M0
	CALL	CRONO
	CJNE	R6, #0, $	;espera o fim do tempo
	MOV	A, P1
	SJMP	LDESCE
SOBE:	CALL	DIRETO
	RL	A
	MOV	P1, A
	CALL	M0
	CALL	CRONO
	CJNE	R6, #0, $	;espera o fim do tempo
	MOV	A, P1
	INC	R5
	SJMP	LSOBE

DIRETO:	PUSH	ACC
	MOV	DPTR, #MCC
	MOV	A, #12H		;motor direto
LIGA:	MOVX	@DPTR, A
	POP	ACC
	RET
INDIRET:	PUSH	ACC
	MOV	DPTR, #MCC
	MOV	A, #11H		;motor reverso
	SJMP	LIGA

CRONO:	MOV	R6, #1		;FLAG pra indicar que INICIOU CRONOMETRO
	MOV	R7, #100		; 100* 50ms == 5s
	SJMP	F
L1:	MOV	R6, #0		;FLAG pra indicar que terminou
	RET			;
F:	MOV	TH0, #HIGH(19455)	; confg. temporizador 0 para 50ms
	MOV	TL0, #LOW(19455)	; confg. temporizador 0 para 50ms
	SETB	TR0		;liga temporizador 0
	RET

TIMER:	DJNZ	R7, F
	SJMP	L1

M0:	PUSH	ACC
	MOV	A, R5
	MOV	B, #18
	MOV	R2, #0		;contador para leitura do texto
	MUL	AB
L:	PUSH	ACC
	ADD	A, R2
	MOV	DPTR, #TXT0	;pega o endereço inicial do texto
	MOVC	A, @A+DPTR
	CJNE	A, #0FFH, ENVIA
	POP	ACC
	POP	ACC
	RET
ENVIA:	MOV	SBUF, A		;coloca o caracter a ser transmitido
	JNB	TI, $		;espera transmitir
	POP	ACC
	CLR	TI
	INC	R2
	SJMP	L

TXT0:	DB	'PAVIMENTO TERREO', 13, 0FFH
TXT1:	DB	'PRIMEIRO ANDAR  ', 13, 0FFH
TXT2:	DB	'SEGUNDO ANDAR   ', 13, 0FFH
TXT3:	DB	'TERCEIRO ANDAR  ', 13, 0FFH
TXT4:	DB	'QUARTO ANDAR    ', 13, 0FFH
TXT5:	DB	'QUINTO ANDAR    ', 13, 0FFH
TXT6:	DB	'SEXTO ANDAR     ', 13, 0FFH
TXT7:	DB	'SETIMO ANDAR    ', 13, 0FFH


	END

