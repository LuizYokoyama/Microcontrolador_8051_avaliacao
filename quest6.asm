
MCC	EQU	6000H
MP	EQU	2000H
	ORG	00H
	SJMP	INICIO

	ORG	03H		;interrupção 0
	CALL	PRESS
	RETI

	ORG	0BH		;interrupção do timer zero
	CALL	TIMER
	RETI

	ORG	30H
INICIO:	MOV	SP, #2FH
	MOV	IE, #83H	;habilita timer zero e int 0
	MOV	IP, #2		;timer 0 tem prioridade
	MOV	TCON, #1	;interrupção exeterna 0 por transição
	MOV	TMOD, #21h	;configura temporizador zero no modo 1 e temp1 no modo 2
	MOV	SCON, #40H	;Serial no modo 1
	MOV	TH1, #0FAH	;taxa de 4.800bps
	SETB	TR1		;dispara timer1
	MOV	P1, #1		;INICIA no andar 0
	MOV	R5, #0		;numero do ANDAR

	CALL	INF
	MOV	A, P1
	SJMP	$		;loop infinito

PRESS:	CLR	P3.7
	CLR	P2.6
	CLR	P2.5
	MOV	R0, P0
	SETB	P3.7
	SETB	P2.6
	SETB	P2.5
	PUSH	ACC
	MOV	A, R0
	CJNE	A, #7, VALIDAR
OK:	MOV	B, R5
	CJNE	A, B, DECISAO
	POP	ACC
	RET
DECISAO:	JNC	PSOBE
	SJMP	PDESCE
VALIDAR:	JNC	INVALID
	SJMP	OK
INVALID:	POP	ACC
	RET

PDESCE:	POP	ACC		;POP e loop de descer
LDESCE:	JNB	P1.0, DESCE	;LOOP de descer
LSOBE:	JNB	P1.7, SOBE	;LOOP de subir
DESCE:	CALL	INDIRET
	CALL	AGUARD
	RR	A
	MOV	P1, A
	DEC	R5
	CALL	INF
	PUSH	ACC
	MOV	A, R0
	MOV	B, R5
	CJNE	A, B, PDESCE
	POP	ACC
	CALL	STOP
	RET
PSOBE:	POP	ACC		;POP e loop de subir
SOBE:	CALL	DIRETO
	CALL	AGUARD
	RL	A
	MOV	P1, A
	INC	R5
	CALL	INF
	PUSH	ACC
	MOV	A, R0
	MOV	B, R5
	CJNE	A, B, PSOBE
	POP	ACC
	CALL	STOP
	RET
DIRETO:	PUSH	ACC
	MOV	DPTR, #MCC
	MOV	A, #12H		;motor direto
LIGA:	MOVX	@DPTR, A
	POP	ACC
	RET
INDIRET:PUSH	ACC
	MOV	DPTR, #MCC
	MOV	A, #11H		;motor reverso
	SJMP	LIGA

STOP:	PUSH	ACC
	MOV	DPTR, #MCC
	MOV	A, #13H		;motor cc DESLIGADO
	MOVX	@DPTR, A
	POP	ACC
	CALL	ANT
	CALL	AGUARD
	CALL	HOR
	RET

AGUARD:	CALL	CRONO
	CJNE	R6, #0, $	;espera o fim do tempo
	RET

CRONO:	MOV	R6, #1		;FLAG pra indicar que INICIOU CRONOMETRO
	MOV	R7, #100	; 100* 50ms == 5s
	SJMP	F
L1:	MOV	R6, #0		;FLAG pra indicar que terminou
	RET			;
F:	MOV	TH0, #HIGH(19455)	; confg. temporizador 0 para 50ms
	MOV	TL0, #LOW(19455)	; confg. temporizador 0 para 50ms
	SETB	TR0		;liga temporizador 0
	RET

TIMER:	DJNZ	R7, F
	SJMP	L1

INF:	PUSH	ACC
	MOV	A, R5
	MOV	B, #18		;comprimento do texto
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

ANT:	PUSH	ACC
	MOV	A, #99H
	MOV	R1, #0		;contador de passos
ANTL:	RL	A
	INC	R1
	MOV	DPTR, #MP	; ENDEREÇO do motor de passo
	MOVX	@DPTR, A
	LCALL	DELAY1
	CJNE	R1, #90, ANTL	;90 passos de 4 graus
	POP	ACC
	RET

HOR:	PUSH	ACC
	MOV	A, #66H
	MOV	R1, #0		;contador de passos
HORL:	RR	A
	INC	R1
	MOV	DPTR, #MP	; ENDEREÇO do motor de passo
	MOVX	@DPTR, A
	LCALL	DELAY1
	CJNE	R1, #90, HORL	;90 passos de 4 graus
	POP	ACC
	RET

DELAY1:	MOV	R4, #04FH
DELAY2:	MOV	R3, #0FFH
	DJNZ	R3, $
	DJNZ	R4, DELAY2
	RET


TXT0:	DB	'PAVIMENTO TERREO', 13, 0FFH
TXT1:	DB	'PRIMEIRO ANDAR  ', 13, 0FFH
TXT2:	DB	'SEGUNDO ANDAR   ', 13, 0FFH
TXT3:	DB	'TERCEIRO ANDAR  ', 13, 0FFH
TXT4:	DB	'QUARTO ANDAR    ', 13, 0FFH
TXT5:	DB	'QUINTO ANDAR    ', 13, 0FFH
TXT6:	DB	'SEXTO ANDAR     ', 13, 0FFH
TXT7:	DB	'SETIMO ANDAR    ', 13, 0FFH


	END



