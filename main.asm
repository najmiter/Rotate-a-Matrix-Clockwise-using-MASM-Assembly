include Utilities.inc

.code
main proc
beginning:
	; Create a private heap for the this program
	invoke HeapCreate, 0, heap_start, heap_end
	mov heap_handle, eax

choice:
	call clrscr
	call waqar

	cmp eax, 3
	je random
	cmp eax, 2
	je file
	cmp eax, 1
	je user_input
	cmp eax, 0
	je to_infinity_and_beyond


	mWrite	"INVALID INPUT"
	mWrite	10
	mWrite	"PRESS ANY KEY TO TRY AGAIN..."
	call ReadChar
	call clrscr
	jmp choice

random:
	mWrite	"Well in that case, we need to know the dimensions"
	mWrite	10
	mWrite	"Enter number of rows:> "
	call ReadDec
	mov dimension_box[4], eax
	mWrite	"Enter number of columns:> "
	call ReadDec
	mov dimension_box[0], eax

	mov eax, dimension_box[0]
	imul eax, dimension_box[4]
	mov dimension_box[8], eax

	mov ecx, dimension_box[8]
	imul ecx, 4 ; dword takes 4 bytes per element
	invoke HeapAlloc, heap_handle, HEAP_ZERO_MEMORY, ecx
	mov random_matrix_array, eax

	mov edx, random_matrix_array
	mov ebx, offset dimension_box
	call fill_array_with_random_values

	mov ecx, dimension_box[8]
	imul ecx, 4
	add ecx, dimension_box[4]
	push ecx
	invoke HeapAlloc, heap_handle, HEAP_ZERO_MEMORY, ecx
	mov random_matrix_string, eax
		
	mov edx, random_matrix_string
	mov ebx, random_matrix_array
	mov esi, offset dimension_box
	invoke int_to_string_converter

	; Create a file to store to the string
	; input from the user
	mov edx, offset matrix_txt
	invoke CreateOutputFile
	mov matrix_file_handle, eax

	; Write the string to the file
	mov edx, random_matrix_string
	pop ecx
	invoke WriteToFile
	mov matrix_string_length, eax
	
	; Close the opened file for writing
	mov eax, matrix_file_handle
	invoke CloseFile

	invoke HeapFree, heap_handle, HEAP_ZERO_MEMORY, random_matrix_string

	jmp file
		

user_input:
	invoke HeapAlloc, heap_handle, HEAP_ZERO_MEMORY, max_matrix_area
	mov matrix_string_from_user_input, eax
	
	mwrite "Enter your matrix:"
	mwrite 10
	
	; Get input into the string
	mov edx, matrix_string_from_user_input
	mov ecx, max_matrix_area
	invoke get_input_matrix
	mov matrix_string_length, ebx
	inc matrix_string_length

	; Create a file to store to the string
	; input from the user
	mov edx, offset matrix_txt
	invoke CreateOutputFile
	mov matrix_file_handle, eax

	; Write the string to the file
	mov edx, matrix_string_from_user_input
	mov ecx, matrix_string_length
	invoke WriteToFile
	
	; Close the opened file for writing
	mov eax, matrix_file_handle
	invoke CloseFile

file:
	invoke HeapAlloc, heap_handle, HEAP_ZERO_MEMORY, matrix_string_length
	mov matrix_input_from_file, eax

	; Open a file for inputing data
	mov edx, offset matrix_txt
	invoke OpenInputFile
	mov heap_handle_for_file_input_matrix, eax

	; Read from the opened file into the
	; new string allocated on the heap
	mov eax, heap_handle_for_file_input_matrix
	mov ecx, matrix_string_length
	mov edx, matrix_input_from_file
	invoke ReadFromFile

	; Close the input file
	mov eax, heap_handle_for_file_input_matrix
	invoke CloseFile

	; mov edx, matrix_input_from_file
	;invoke print_matrix
	
dimensions:
	mov edx, matrix_input_from_file
	mov ebx, offset dimension_box
	invoke find_matrix_dimensions

allocate_input_array:
	mov ecx, dimension_box[8]
	imul ecx, 5 ; dword takes 4 bytes per element
	invoke HeapAlloc, heap_handle, HEAP_ZERO_MEMORY, ecx
	mov input_dword_array_ptr, eax

convert_string_to_int:
	; Convert the string-numbers into integer-numbers
	mov esi, matrix_input_from_file	; string
	mov ebx, input_dword_array_ptr	; array
	invoke string_to_int_converter


allocate_output_matrix_array:
	mov ecx, dimension_box[8]
	imul ecx, 4 ; dword takes 4 bytes per element
	invoke HeapAlloc, heap_handle, HEAP_ZERO_MEMORY, ecx
	mov output_rotated_matrix_array, eax

	; Rotate the matrix
	mov edx, output_rotated_matrix_array
	mov ebx, input_dword_array_ptr
	mov esi, offset dimension_box
	invoke rotate_matrix


allocate_output_matrix_string:
	; Create a new heap
	invoke HeapCreate, 0, other_heap_start, other_heap_limit
	mov other_heap_handle, eax

	; Allocate the required bytes for the output string
	mov ecx, dimension_box[8]
	imul ecx, 5 ; each pixel is three characters long, there're spaces, '\n' and '\r'
	invoke HeapAlloc, other_heap_handle, HEAP_ZERO_MEMORY, ecx
	mov output_rotated_matrix_string, eax
	
	mov edx, output_rotated_matrix_string
	mov ebx, output_rotated_matrix_array
	mov esi, offset dimension_box
	invoke int_to_string_converter

allocat_final_string:
	mov ecx, dimension_box[8]
	imul ecx, 5
	imul ecx, 3
	invoke HeapAlloc, other_heap_handle, HEAP_ZERO_MEMORY, ecx
	mov output_final_string_ptr, eax

join_final_strings:
	mov edx, matrix_input_from_file
	mov ebx, output_rotated_matrix_string
	mov edi, output_final_string_ptr
	invoke join_strings

	mWriteString lines
	mov edx, output_final_string_ptr
	invoke print_matrix


	mov edx, offset output_matrix_txt
	call CreateOutputFile
	mov matrix_file_handle, eax

	mov edx, output_final_string_ptr
	mov ecx, esi
	mov eax, matrix_file_handle
	call WriteToFile

	mov eax, matrix_file_handle
	call CloseFile



return:
	
	mWriteString	lines
	mWrite			"Wanna go again? (y/n) >>> "
	call			ReadChar
	call			WriteChar
	.if al == 'y'
		invoke HeapDestroy, heap_handle
		invoke HeapDestroy, other_heap_handle
		jmp beginning
	.endif

to_infinity_and_beyond:
	mWriteString	lines
	mWrite			" ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### "
	mWriteString	lines
	mWrite			"|--------------------> HAVE A NICE DAY <--------------------|"
	mWriteString	lines

	invoke ExitProcess, 0
main endp


; <><><><><><><> 
;   ENTRY POINT 
; <><><><><><><>
end main
