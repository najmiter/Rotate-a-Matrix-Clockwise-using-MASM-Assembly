include Utilities.inc

.code

is_valid_character proc uses eax
	.if (al >= 48 && al <= 57) || (al == 32 || al == 13 || al == 10)
		stc
	.else
		clc
	.endif
	ret
is_valid_character endp

is_printable_character proc uses eax
	.if (al >= 48 && al <= 57)\
		|| (al == 32 || al == 13 || al == 10 || al == 9)\
		|| (al >= 65 && al <= 90)\
		|| (al >= 97 && al <= 123)

		stc
	.else
		clc
	.endif
	ret
is_printable_character endp

; ------------------------------------------------------------------
; get_input_matrix
; RECIEVES:	
;		1- String offset	(edx)
;		2- String length	(ecx)
; SPITS:
;		1- String			(edx)
;		2- Number of spaces (ebx)
; ------------------------------------------------------------------

get_input_matrix proc uses ecx edx

	; i = ebx
	; string = edx
	; string[i]

	
	dec ecx
	mov al, 0
	mov ebx, 0
	.while ebx < ecx
		call readchar
		
		.if al == '.'
			jmp pappu
		.elseif al == 0Dh
			mov byte ptr [edx + ebx], 0Dh
			inc ebx
			mov byte ptr [edx + ebx], 0Ah
			call crlf
			inc ebx
		.elseif al >= 48 && al <= 57 || al == 32
			call writechar
			mov [edx + ebx], al
			inc ebx
			
		.endif

	.endw

pappu:
	ret

get_input_matrix endp


; ------------------------------------------------------------------
; find_matrix_dimensions
; RECIEVES:	
;		1- String offset			(edx)
; SPITS:
;		1- Number of rows			(dimenison_box[0])
;		2- Number of columns		(dimenison_box[4])
;		3- Number of elements		(dimenison_box[8])
; ------------------------------------------------------------------
find_matrix_dimensions proc
	pushad
	push ebx

	mov al, [edx]
	mov ecx, 1		; number of columns
	mov ebx, 0		; i = ebx
	mov esi, 0		; index of the first '\n'
	mov edi, 1		; number of characters (corrected)
	jmp check_condition
	keep_checking:
		
		.if al == 13 && esi == 0
			mov esi, ebx
			inc esi
		.endif

		.if esi == 0 && al == 32
			inc ecx
		.endif

		.if al != 13
			inc edi
		.endif

		inc ebx
		mov al, byte ptr [edx + ebx]
		
	check_condition:
		call is_valid_character ; set carry flag if valid
		jc keep_checking
		jmp return
return:
	pop ebx

	mov edx, 0
	mov eax, edi
	div esi
	mov [ebx], eax	; rows

	mov [ebx + 4], ecx	; columns
	mul ecx
	mov [ebx + 8], eax
	popad
	ret

find_matrix_dimensions endp

; ------------------------------------------------------------------
; print_matrix
; RECIEVES:	
;		1- String offset				(edx)
; ------------------------------------------------------------------
print_matrix proc uses ebx eax
	mov al, byte ptr [edx]
	mov ebx, 0
	jmp check_condition
	keep_printing:
		call WriteChar
		inc ebx
		mov al, byte ptr [edx + ebx]

		.if al == 10
			call writechar
			;mWrite	9d
			inc ebx
			mov al, byte ptr [edx + ebx]
			
		.endif
		
	check_condition:
		call is_printable_character
		jc keep_printing
		jmp return
return:
	ret

print_matrix endp


; ------------------------------------------------------------------
; string_to_int_converter
; RECIEVES:	
;		1- String offset			(edx)
;		2- Array offset				(ebx)
; SPITS:
;		1- Filled array				(ebx)
; ------------------------------------------------------------------
string_to_int_converter proc
	pushad
	; s_numbers = esi
	; i_numbers = ebx

	xor ecx, ecx	; i
	xor edi, edi	; j
	jmp check_condition
	keep_it_going:	
		xor edx, edx
		mov [ebx + edi], edx
		.while al != 32
			
			call is_valid_character ; set carry flag if valid
			jnc return
			
			.if al == 13
				inc ecx
				jmp after_maths
			.endif

			push ebx
			push edi

			movzx edx, byte ptr [esi + ecx]
			sub edx, 48
			imul edx, pixel_divider
			
			add [ebx + edi], edx

			push eax
			xor edx, edx
			mov eax, pixel_divider
			div by_ten
			mov pixel_divider, eax
			pop eax

			inc ecx
			mov al, byte ptr [esi + ecx]

			pop edi
			pop ebx

		.endw
	after_maths:
		push eax
		mov eax, divider
		mov pixel_divider, eax
		pop eax

		add edi, 4
		inc ecx
		
	check_condition:
		mov al, [esi + ecx]
		call is_valid_character ; set carry flag if valid
		jc keep_it_going
		jmp return
return:
	popad
	ret
string_to_int_converter endp


; ------------------------------------------------------------------
; rotate_matrix 
; RECIEVES:	
;		1- Output Array offset			(edx)
;		2- Input Array offset			(ebx)
; SPITS:
;		1- Rotated array				(edx)
; ------------------------------------------------------------------
rotate_matrix proc
	pushad
	; edx = output
	; ebx = input
	; esi = dimensions

	mov edi, [esi]		; rows
	mov ecx, [esi + 4]	; columns
	mov eax, [esi + 8]	; size
	
	mov _columns, ecx
	mov _rows, edi
	mov array_size, eax
	
	xor eax, eax
	xor edi, edi
	xor ecx, ecx

	.while ecx < array_size
		mov edi, array_size		; distributer
		sub edi, _columns
		
		.while edi < array_size
			push ecx
			push edi
			
			imul edi, 4		; 0
			imul ecx, 4		; 0
			mov eax, [ebx + edi]
			mov [edx + ecx], eax

			
			pop edi
			sub edi, _columns
			
			pop ecx
			inc ecx
		.endw
		
		inc array_size
	.endw

return:
	popad
	ret

rotate_matrix endp

; ------------------------------------------------------------------
; int_string_converter
; RECIEVES:	
;		1- String offset			(edx)
;		2- Array offset				(ebx)
; SPITS:
;		1- String					(edx)
; ------------------------------------------------------------------
int_to_string_converter proc
	pushad

	mov edi, [esi]		; rows
	mov ecx, [esi + 4]	; columns
	mov eax, [esi + 8]	; size

	mov _rows, edi
	mov _columns, ecx
	mov array_size, eax

	xor eax, eax
	xor ecx, ecx

	mov esi, 0		; string indexes
	mov ecx, 0
	.while ecx < array_size
		push edi			; for later use
		;xor edi, edi
		
		push ecx
		imul ecx, 4
		mov eax, [ebx + ecx]	; number = eax
		pop ecx

		mov edi, pixel_divider	; divider = edi
		.while edi != 0
			push edx
			xor edx, edx
			div edi
			add eax, 48
			mov remainder_holder, edx

			pop edx
			mov byte ptr [edx + esi], al
			inc esi

			push edx
			
			mov eax, edi
			xor edx, edx
			div by_ten
			mov edi, eax

			pop edx

			mov eax, remainder_holder
			
		.endw

		inc ecx
		
		pop edi
		dec edi
		.if edi == 0
			mov byte ptr [edx + esi], 13
			inc esi
			mov byte ptr [edx + esi], 10
			inc esi
			mov edi, _rows
		.else
			mov byte ptr [edx + esi], 32
			inc esi
		.endif


	.endw

return:
	popad
	ret

int_to_string_converter endp

; ------------------------------------------------------------------
; join_strings proto
; RECIEVES:	
;		1- Source1 string offset			(edx)
;		2- Source2 string offset			(ebx)
;		3- Destination string offset		(edi)
; SPITS:
;		1- Destination string offset		(edi)
; ------------------------------------------------------------------
join_strings proc uses edx ebx edi
	xor esi, esi

	mov al, original_text[esi]
	.while al != 0
		mov [edi + esi], al
		inc esi
		mov al, [original_text + esi]

	.endw
	
	
	xor ecx, ecx
	mov al, byte ptr [edx + ecx]
	.while al != 0
		mov byte ptr [edi + esi], al
		inc esi
		inc ecx
		mov al, byte ptr [edx + ecx]
	.endw

	xor ecx, ecx
	mov al, rotated_text[ecx]
	.while al != 0
		mov [edi + esi], al
		inc esi
		inc ecx
		mov al, [rotated_text + ecx]
	.endw


	xor ecx, ecx
	mov al, byte ptr [ebx + ecx]
	.while al != 0
		mov byte ptr [edi + esi], al
		inc esi
		inc ecx
		mov al, byte ptr [ebx + ecx]
	.endw


return:
	ret

join_strings endp

; ------------------------------------------------------------------
; waqar proto
; RECIEVES:	
; 
; SPITS:
;		1- Choice	(eax)
; ------------------------------------------------------------------
waqar proc uses edx
	mov edx, offset user_se_input_lyn_txt
	call OpenInputFile
	mov matrix_file_handle, eax

	mov eax, matrix_file_handle
	mov ecx, 499
	mov edx, offset user_se_input_lyn_string
	invoke ReadFromFile

	mov edx, offset user_se_input_lyn_string
	call WriteString
	call ReadDec
	push eax

	mov eax, matrix_file_handle
	call CloseFile

	pop eax

	ret
waqar endp


fill_array_with_random_values proc
	pushad
	call Randomize
	mov eax, [ebx + 8]
	mov array_size, eax
	
	xor edi, edi
	xor ecx, ecx
	.while ecx < array_size
		call Random32
		push edi
		push edx
		xor edx, edx
		div _thousand
		mov eax, edx

		pop edx
		imul edi, 4
		mov [edx + edi], eax
		pop edi
		inc edi
		inc ecx
	.endw


	popad
	ret
fill_array_with_random_values endp

end
