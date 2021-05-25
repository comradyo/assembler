MYCODE SEGMENT 'CODE'
	ASSUME CS:MYCODE, DS:MYCODE 

letter DB '€'

;Zc?aa?  ?®­a®«?
CLRSCR PROC
	mov ax, 03
	int 10h
    	RET
CLRSCR ENDP

; Z¦?¤ ­?? § ??ae?­?i ?a®?a ¬¬e
GETCH PROC
	MOV AH, 01H
	INT 021H
	RET
GETCH ENDP
	
; ‚e?®¤ ®¤­®?® a?¬?®« 
PUTCH PROC
	MOV AH, 02H
	INT 021H
	RET
PUTCH ENDP

;??a??®¤ ­  ­®?ai aaa®?a ? ? a?a? 
CLRF PROC
	MOV DL, 0AH
     	INT 021H
     	MOV DL, 13
     	INT 021H
     	RET
CLRF ENDP



;–??«, ? ?®a®a®¬ ?e?®«­i?aai ?a®?a ¬¬ 
CYCLE PROC
	MOV CX, 10
myloop:
	MOV DL, letter
	CALL PUTCH
	CALL CLRF
	INC letter
	loop myloop
	RET
CYCLE ENDP
   
				
START:
; Zc?aa?  i?a ­ 
	CALL CLRSCR
; ‡ ?aa§?  a??¬?­a­®?® a???aaa  ¤ ­­ea DS 
	PUSH CS
	POP DS
; ‚e?®¤ a?¬?®«®? ­  i?a ­
	CALL CYCLE
 	CALL GETCH
; ‚ea®¤ ?§ ?a®?a ¬¬e
	MOV AL, 0
	MOV AH, 4CH
	INT 21H
MYCODE ENDS
END START