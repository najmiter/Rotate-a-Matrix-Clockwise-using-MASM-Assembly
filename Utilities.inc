include irvine32.inc
include macros.inc

; ------------------------------------------------------------------
get_input_matrix proto
; RECIEVES:	
;		1- String offset	(edx)
;		2- String length	(ecx)
; SPITS:
;		1- String		(edx)
;		2- Number of spaces 	(ebx)
; ------------------------------------------------------------------

; ------------------------------------------------------------------
print_matrix proto
; RECIEVES:	
;		1- String offset	(edx)
; ------------------------------------------------------------------

; ------------------------------------------------------------------
find_matrix_dimensions proto
; RECIEVES:	
;		1- String offset		(edx)
; SPITS:
;		1- Number of rows		(dimenison_box[0])
;		2- Number of columns		(dimenison_box[4])
;		3- Number of elements		(dimenison_box[8])
; ------------------------------------------------------------------

; ------------------------------------------------------------------
string_to_int_converter proto
; RECIEVES:	
;		1- String offset			(edx)
;		2- Array offset				(ebx)
; SPITS:
;		1- Filled array				(ebx)
; ------------------------------------------------------------------

; ------------------------------------------------------------------
rotate_matrix proto
; RECIEVES:	
;		1- Output Array offset			(edx)
;		2- Input Array offset			(ebx)
; SPITS:
;		1- Rotated array			(edx)
; ------------------------------------------------------------------

; ------------------------------------------------------------------
int_to_string_converter proto
; RECIEVES:	
;		1- String offset			(edx)
;		2- Array offset				(ebx)
; SPITS:
;		1- String				(edx)
; ------------------------------------------------------------------

; ------------------------------------------------------------------
join_strings proto
; RECIEVES:	
;		1- Source1 string offset		(edx)
;		2- Source2 string offset		(ebx)
;		3- Destination string offset		(edi)
; SPITS:
;		1- Destination string offset		(edi)
; ------------------------------------------------------------------

; ------------------------------------------------------------------
waqar proto
; RECIEVES:	
; 
; SPITS:
;		1- Choice	(eax)
; ------------------------------------------------------------------

fill_array_with_random_values proto

pixel_size		= 3
max_matrix_area		= 1000

heap_start		= 10000000
heap_end		= 900000000
other_heap_start	= 90000000
other_heap_limit	= 999000000

.data
	matrix_txt					byte "Matrix.txt", 0
	output_matrix_txt				byte "Output Matrix.txt", 0
	user_se_input_lyn_txt				byte "user se input lyn.txt", 0

	original_text					byte "The followig is the matrix read from the file", 10, 10, 0
	rotated_text					byte 10, "The following is the rotated matrix", 10, 10, 0

	user_se_input_lyn_string			byte 500 dup(0)


	heap_handle					handle	?
	other_heap_handle				handle	?
	matrix_file_handle				handle	?
	heap_handle_for_file_input_matrix		handle	?
	heap_handle_for_user_input_matrix		handle	?
	heap_handle_for_input_dword_array_ptr		handle	?
	heap_handle_for_output_rotated_matrix_string	handle	?
	heap_handle_for_output_rotated_matrix_array	handle	?
	
	matrix_string_from_user_input			dd	?
	matrix_input_from_file				dd	?

	random_matrix_string				dd	?
	random_matrix_array				dd	?
	random_matrix_string_rotated			dd	?
	random_matrix_array_rotated			dd	?

	output_rotated_matrix_string			dd	?
	output_rotated_matrix_array			dd	?

	output_final_string_ptr				dd	?						
	
	matrix_string_length				dd	max_matrix_area

	input_dword_array_ptr				dd	?


	; rows, columns, size
	dimension_box				dd	3 dup(0)
	lines					db	10,10,10,0

	by_ten					dd	10
	by_four					dd	4
	_zero					dd	0
	_thousand				dd	1000

	array_size				dd	?
	_columns				dd	?
	_rows					dd	?
	remainder_holder			dd	?

	pixel_divider				dd 100
	divider					dd 100

