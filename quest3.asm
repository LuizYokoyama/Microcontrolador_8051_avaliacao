
MCC	EQU	6000H

	ORG	00H
	SJMP	INICIO

	ORG	0BH		;interrupção do timer zero
	CALL	TIMER
	RETI

	ORG	30H
INICIO:	MOV	SP, #2FH
	MOV	IE, #82H	;habilita timer zero
	MOV	TMOD, #1	;configura temporizador zero no modo 1
	MOV	P1, #1		;INICIA no andar 0

	MOV	A, P1
	CALL	PRACIMA
	CALL	CRONO
	CJNE	R6, #0, $	;espera o fim do tempo
LDESCE:	JNB	P1.0, DESCE
LSOBE:	JNB	P1.7, SOBE
	SJMP	DESCE
DESCE:	PUSH	ACC
	MOV	DPTR, #MCC
	MOV	A, #11H		;motor reverso
	MOVX	@DPTR, A
	POP	ACC
	RR	A
	MOV	P1, A
	CALL	CRONO
	CJNE	R6, #0, $	;espera o fim do tempo
	MOV	A, P1
	SJMP	LDESCE
SOBE:	CALL 	PRACIMA
	RL	A
	MOV	P1, A
	CALL	CRONO
	CJNE	R6, #0, $	;espera o fim do tempo
	MOV	A, P1
	SJMP	LSOBE
	
PRACIMA:PUSH	ACC
	MOV	DPTR, #MCC
	MOV	A, #12H		;motor direto
	MOVX	@DPTR, A
	POP	ACC
	RET

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

	END
