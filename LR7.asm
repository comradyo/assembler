MYCODE SEGMENT 'CODE'     
    	ASSUME CS: MYCODE, DS:MYCODE
    	  
s_enter_number db 'Введите число (длинный адрес : HHHH:HHHH) > $'
;Число в 16 системе счисления 
digit_16 dw 0  
i db 0 
hex_table db '0123456789ABCDEF$'
s_put_ax db 'Значение регистра AX: $'
s_put_dx db 'Значение регистра DX: $'
  
;!!!!!!!!!!!!!!ДОП ЗАДАНИЕ:
;!!!!!!!!!!!!!!ВЫВЕСТИ РЕГИСТРЫ AX, DX

	;========Д=О=П=О=Л=Н=И=Т=Е=Л=Ь=Н=О=Е===З=А=Д=А=Н=И=Е==========
	
	EXTRATASK PROC 
	
	mov ax, 'АА'
	mov dx, 'БВ'
	
	push dx
		;Внутри используются ax, dx, пушатся в самой функции
		call CLRF      
		
		;Вывод строки 'Значение регистра AX: $'
		push ax
			mov ah, 09h
			mov dx, offset s_put_ax
			int 21h
		pop ax
		
		push ax
			push bx
				mov bx, ax
				call PUTAX
			pop bx
		pop ax
		
		call CLRF
	pop dx
	
	push dx
	
		;Вывод строки 'Значение регистра DX: $'
		push ax
			push dx
				mov ah, 09h
				mov dx, offset s_put_dx
				int 21h
			pop dx
		pop ax
		
		push ax
			push bx
				mov bx, dx
				call PUTAX
			pop bx
		pop ax
		
		call CLRF
	pop dx	
	
		RET
		
	EXTRATASK ENDP
	
	PUTAX PROC
	
		;Верхний байт 
		push bx
		mov bl, bh
		call translate  
		call putch 
		pop bx
		
		;Нижний байт
		call translate
		call putch
		    
		mov dl, 'h'
		call putch
		
		RET
	PUTAX ENDP

	PUTDX PROC
	
		RET
	PUTDX ENDP
	
	;=============================================================

START:          
	
	CALL CLRSCR

    	PUSH CS
    	POP DS
    	 
start_input:
          
	mov i, 0 
	mov digit_16, 0
          
	;В bx лежит число в 16-ричной системе счисления
	xor bx, bx
	xor ax, ax
	xor dx, dx
	
	;Печать с просьбой ввести строку  
	mov ah, 09h
	mov dx, offset s_enter_number
	int 21h
          
	;Считываем число (циклически считывая цифры)
	jmp read_digit
	
	after_digit_is_read:
		
	output_hex:   
 		mov digit_16, bx
 		
   		mov dl, ' '
     		call putch
     		mov dl, '='
     		call putch
     		mov dl, ' '
     		call putch
     		
     		;Верхний байт 
		push bx
		mov bl, bh
		call translate  
		call putch 
		pop bx
		
		;Нижний байт
		call translate
		call putch
		    
		mov dl, 'h'
		call putch
   		mov dl, ' '
     		call putch
     		mov dl, '='
     		call putch
     		mov dl, ' '
     		call putch
		
		mov ax, digit_16
		;Без этого засорится
		push 0
		
	hex_to_dec:   
		xor dx, dx
		mov bx, 10
		;В dl будет dx/bx, в dh - dx mod bx
		div bx
		
		push ax
		mov al,dl 
		add al, '0' 
		mov dl, al  
		pop ax 
		  
		push dx
		;Когда ax = 0       
		cmp ax, 0
			je output_dec  
		jmp hex_to_dec
	 
	output_dec:
		pop dx
		call putch  
		cmp dx, 0
			je clrf_and_start_input
		jmp output_dec
		
	clrf_and_start_input:
		
		;ДОПОЛНИТЕЛЬНОЕ ЗАДАНИЕ
		call EXTRATASK
		
		call CLRF
		jmp start_input
		
add_to_hex:
	add bl, dl    
	inc i
	cmp i, 4
		je after_digit_is_read
	;Сдвигаем bx на 4 бита
	shl bx, 4
	jmp read_digit

;Считывание цифры		
read_digit:    
	call getch
	mov dl, al 
	cmp dl, '*'
		je endprog
	cmp dl, '9'
		;ja <=> '>'
		ja check_letter
	cmp dl, '0'
		;jae <=> '>='
		jae is_digit
		
check_letter:
	cmp dl, 'F'
		ja endprog
	cmp dl, 'A'
		jae is_letter
	 	
is_digit:
	sub dl, '0'
	jmp add_to_hex
	
is_letter:
	;37h - это 'A'
	sub dl, 37h
	jmp add_to_hex

;Конец программы	
endprog:
    	MOV AL, 0
    	MOV AH, 4CH
    	INT 21H  

;============================Ф=У=Н=К=Ц=И=И==============================
	
;Очистка экрана
CLRSCR PROC
	mov ax, 03
	int 10h
    	RET
CLRSCR ENDP
			   
;Вывод символа
PUTCH PROC
	push ax
	MOV AH, 02H
	INT 021H
	pop ax
	RET
PUTCH ENDP  

;Ввод символа
GETCH PROC
	MOV AH, 01H
	INT 021H
	RET
GETCH ENDP  

;Перевод на следующую строку
CLRF PROC
	push ax
	push dx
	;Прерывание, которое будет выводить символ перевода на следующую строку
         	mov ah, 02
         	;Вывод символа перевода стрелки вниз
	MOV DL, 0AH
     	INT 021H
     	MOV DL, 13
     	INT 021H
     	pop dx
     	pop ax
     	RET
CLRF ENDP   

;Перевод из 16 в 10
TRANSLATE PROC
    	mov al, bl
    	PUSH ax
	;Сохраняем в регистр BX адрес hex
    	lea bx, hex_table
    	;Двигаем регистр вправо на 4 бита, получаем 4 старших разряда
    	shr al, 4
 	;XLAT загружает в регистр AL элемент таблицы. Смещение таблицы задается регистром E (BX), индекс элемента задаётся самим регистром AL
    	xlat
    	mov dx, ax
    	CALL PUTCH
    	POP ax
    	PUSH ax
    	;Логическое и, обрезаем старшие 4 бита, получаем 4 младших
    	and al, 00001111b
    	xlat
    	mov dx,ax
    	POP ax    
    	RET
TRANSLATE ENDP  

MYCODE ENDS
END START