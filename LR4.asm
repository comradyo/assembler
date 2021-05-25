MYCODE SEGMENT 'CODE'
	ASSUME CS:MYCODE, DS:MYCODE 
	
letter DB ''  
hex DB 'FEDCBA9876543210'
dash DB ' - '


CLRSCR PROC
	mov ax, 03
	int 10h
    	RET
CLRSCR ENDP

CLRF PROC
	MOV DL, 0AH
     	INT 021H
     	MOV DL, 13
     	INT 021H
     	RET
CLRF ENDP

PUTCH PROC
	MOV AH, 02H
	INT 021H
	RET
PUTCH ENDP


GETCH PROC
	MOV AH, 01H
	INT 021H
	RET
GETCH ENDP

;перевод в 16 систему счисления
TRANSLATE PROC
    	mov al, letter
    	mov ah, al 
    	push ax
    	;Сохраняем в регистр BX адрес hex
    	LEA BX, hex
    	;Двигаем регистр вправо на 4 бита, получаем 4 старших разряда
    	
    	not al
    	shr al, 4
    	;XLAT загружает в регистр AL элемент таблицы. Смещение таблицы задается регистром E (BX), индекс элемента задаётся самим регистром AL
    	xlat
    	mov dx, ax
    	CALL PUTCH
    	POP ax
    	PUSH ax
    	;Логическое и, обрезаем старшие 4 бита, получаем 4 младших
    	not al
    	and al, 00001111b
    	xlat
    	mov dx,ax
    	pop ax
    	RET
TRANSLATE ENDP

CYCLE PROC
	;количество итераций
	MOV CX, 20
myloop:

    	MOV DL, letter
    	CALL PUTCH
	MOV DL, ' '
    	CALL PUTCH
    	MOV DL, '-'
    	CALL PUTCH
    	MOV DL, ' '
    	CALL PUTCH
    	
    	CALL TRANSLATE
    	CALL PUTCH
    	MOV DL, 'h'
    	CALL PUTCH
    	;Очистка буфера
    	xor DL, DL
    	CALL CLRF
    	INC letter
LOOP myloop
	RET
CYCLE ENDP

START:
    	CALL CLRSCR
    	    
    	PUSH CS
    	POP DS
    	    
    	CALL GETCH
    	MOV letter, al
    	CALL CLRF
    	

    	CALL CYCLE
 	CALL GETCH
 	
	MOV AL, 0
	MOV AH, 4CH
	INT 21H
    
MYCODE ENDS
END START