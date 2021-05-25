MYCODE SEGMENT 'CODE'     
    	ASSUME CS: MYCODE, DS:MYCODE
    	  
s_enter_number db '������ �᫮ (������ ���� : HHHH:HHHH) > $'
;��᫮ � 16 ��⥬� ��᫥��� 
digit_16 dw 0  
i db 0 
hex_table db '0123456789ABCDEF$'
s_put_ax db '���祭�� ॣ���� AX: $'
s_put_dx db '���祭�� ॣ���� DX: $'
  
;!!!!!!!!!!!!!!��� �������:
;!!!!!!!!!!!!!!������� �������� AX, DX

	;========�=�=�=�=�=�=�=�=�=�=�=�=�=�===�=�=�=�=�=�=�==========
	
	EXTRATASK PROC 
	
	mov ax, '��'
	mov dx, '��'
	
	push dx
		;����� �ᯮ������� ax, dx, ������ � ᠬ�� �㭪樨
		call CLRF      
		
		;�뢮� ��ப� '���祭�� ॣ���� AX: $'
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
	
		;�뢮� ��ப� '���祭�� ॣ���� DX: $'
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
	
		;���孨� ���� 
		push bx
		mov bl, bh
		call translate  
		call putch 
		pop bx
		
		;������ ����
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
          
	;� bx ����� �᫮ � 16-�筮� ��⥬� ��᫥���
	xor bx, bx
	xor ax, ax
	xor dx, dx
	
	;����� � ���졮� ����� ��ப�  
	mov ah, 09h
	mov dx, offset s_enter_number
	int 21h
          
	;���뢠�� �᫮ (横���᪨ ���뢠� ����)
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
     		
     		;���孨� ���� 
		push bx
		mov bl, bh
		call translate  
		call putch 
		pop bx
		
		;������ ����
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
		;��� �⮣� �������
		push 0
		
	hex_to_dec:   
		xor dx, dx
		mov bx, 10
		;� dl �㤥� dx/bx, � dh - dx mod bx
		div bx
		
		push ax
		mov al,dl 
		add al, '0' 
		mov dl, al  
		pop ax 
		  
		push dx
		;����� ax = 0       
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
		
		;�������������� �������
		call EXTRATASK
		
		call CLRF
		jmp start_input
		
add_to_hex:
	add bl, dl    
	inc i
	cmp i, 4
		je after_digit_is_read
	;�������� bx �� 4 ���
	shl bx, 4
	jmp read_digit

;���뢠��� ����		
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
	;37h - �� 'A'
	sub dl, 37h
	jmp add_to_hex

;����� �ணࠬ��	
endprog:
    	MOV AL, 0
    	MOV AH, 4CH
    	INT 21H  

;============================�=�=�=�=�=�=�==============================
	
;���⪠ �࠭�
CLRSCR PROC
	mov ax, 03
	int 10h
    	RET
CLRSCR ENDP
			   
;�뢮� ᨬ����
PUTCH PROC
	push ax
	MOV AH, 02H
	INT 021H
	pop ax
	RET
PUTCH ENDP  

;���� ᨬ����
GETCH PROC
	MOV AH, 01H
	INT 021H
	RET
GETCH ENDP  

;��ॢ�� �� ᫥������ ��ப�
CLRF PROC
	push ax
	push dx
	;���뢠���, ���஥ �㤥� �뢮���� ᨬ��� ��ॢ��� �� ᫥������ ��ப�
         	mov ah, 02
         	;�뢮� ᨬ���� ��ॢ��� ��५�� ����
	MOV DL, 0AH
     	INT 021H
     	MOV DL, 13
     	INT 021H
     	pop dx
     	pop ax
     	RET
CLRF ENDP   

;��ॢ�� �� 16 � 10
TRANSLATE PROC
    	mov al, bl
    	PUSH ax
	;���࠭塞 � ॣ���� BX ���� hex
    	lea bx, hex_table
    	;������� ॣ���� ��ࠢ� �� 4 ���, ����砥� 4 ����� ࠧ�鸞
    	shr al, 4
 	;XLAT ����㦠�� � ॣ���� AL ����� ⠡����. ���饭�� ⠡���� �������� ॣ���஬ E (BX), ������ ����� �������� ᠬ�� ॣ���஬ AL
    	xlat
    	mov dx, ax
    	CALL PUTCH
    	POP ax
    	PUSH ax
    	;�����᪮� �, ��१��� ���訥 4 ���, ����砥� 4 ������
    	and al, 00001111b
    	xlat
    	mov dx,ax
    	POP ax    
    	RET
TRANSLATE ENDP  

MYCODE ENDS
END START