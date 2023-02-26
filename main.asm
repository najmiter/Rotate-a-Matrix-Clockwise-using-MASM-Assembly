include Utilities.inc
include macros.inc

.code
main proc
	; Create a private heap for the this program
	invoke HeapCreate, 0, heap_start, heap_end
	mov heap_handle, eax

jmp file
	
	invoke HeapAlloc, heap_handle_for_user_input_matrix, HEAP_ZERO_MEMORY, max_matrix_area
	mov matrix_string_from_user_input, eax
	
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
	mov esi, matrix_input_from_file
	mov ebx, input_dword_array_ptr
	invoke string_to_int_converter

	;mov ecx, 0
	;.while ecx < 36
	;	mov eax, [ebx + ecx]
	;	call writedec
	;	call crlf
	;	add ecx, 4
	;.endw

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


	;mov ecx, 0
	;.while ecx < 24
	;	mov eax, [edx + ecx]
	;	call writedec
	;	call crlf
	;	add ecx, 4
	;.endw


allocate_output_matrix_string:
	; Create a new heap
	invoke HeapCreate, 0, heap_start, other_heap_limit
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

	mwrite "Original"
	call crlf
	call crlf
	mov edx, matrix_input_from_file
	invoke print_matrix
	
	call crlf
	call crlf
	mwrite "Rotated"
	call crlf
	call crlf
	mov edx, output_rotated_matrix_string
	invoke print_matrix

	invoke ExitProcess, 0
main endp


; <><><><><><><> 
;   ENTRY POINT 
; <><><><><><><>
end main
