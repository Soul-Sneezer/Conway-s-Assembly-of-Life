.data
arguments: .space 1024
n: .space 4
m: .space 4
p: .space 4
list: .space 2048
k: .space 4
mode: .space 4
message: .space 100
bitset: .space 800
matrix: .space 1600
matrix_copy: .space 1600
output: .space 3200
output2: .space 3200
.text
.global main
main:


read_input:
	mov $3, %eax							# argument for read
	xor %ebx, %ebx						# read from stdin
	lea arguments, %ecx				# into buffer named arguments
	mov $1024, %edx						# max size of buffer is 1024 bytes
	int $0x80									# syscall

	lea n, %ebp								# the variables are sequential in memory(I believe), so I get the address of the first one
	xor %eax, %eax						# reset eax
	xor %edi, %edi						# reset edi
parse_values:
	xor %edx, %edx						# reset edx
	movb (%ecx, %edi, 1), %dl # get char
	cmp $97, %dl
	jge copy_word_initialize
	cmp $0, %dl								# compare the char to 0(null), if true jump
	je create_matrix					# to initialize matrix
	cmp $3, %dl								# compare the char to 3(eof), if true jump
	je create_matrix					# to initialize matrix
	cmp $10, %dl							# compare the char to 10(line feed), if true jump
	je found_whitespace				# to found_whitespace
	cmp $32, %dl							# compare the char to 32(whitespace), if true jump
	je found_whitespace				# to found_whitespace
char_to_value:							# convert from char to a digit
	mov $10, %edx
	mul %edx									# shift %eax to the left(in decimal)
	xor %edx, %edx						# reset %edx after multiplication(should be $0 anyway but why risk it?)
	movb (%ecx, %edi, 1), %dl # get char
	sub $48, %dl							# subtract 48(value of '0' in ascii) to get the digit
	add %dl, %al							# add the digit to the value	
	inc %edi									# get to next char
	jmp parse_values					# loop
found_whitespace:
	mov %al, (%ebp, %ebx, 4) 	# move the value from eax back to the variable
	xor %eax, %eax						# reset value in eax
	inc %edi									# get to next char
	inc %ebx									# go to the next variable byte	
	jmp parse_values					# loop
copy_word_initialize:
	lea message, %ebp
	xor %ebx, %ebx
copy_word:
	mov %edx, (%ebp, %ebx, 4)
	inc %ebx
	xor %edx, %edx
	inc %edi
	movb (%ecx, %edi, 1), %dl
	cmp $0, %dl
	je create_matrix
	cmp $3, %dl
	je create_matrix
	cmp $10, %dl
	je create_matrix
	jmp copy_word
create_matrix:
	mov n, %eax
	add $2, %eax
	mov m, %ecx
	add $2, %ecx
	mul %ecx											# get number of elements in matrix
	lea matrix_copy, %ecx
	lea matrix, %ebp					# get address of matrix
initialize_matrix:
	dec %eax									# start from the end of the matrix(easier this way)
	movl $0, (%ecx, %eax, 4)
	movl $0, (%ebp, %eax, 4)		# set value at index %eax to 0
	cmp $0, %eax							# if eax is 0 stop loop
	jne initialize_matrix			# else continue
	lea list, %ebp						# get list of coordinates
	lea matrix, %esi					# get matrix
	mov p, %ebx								# get p(number of coordinates) into %ebx
	xor %edi, %edi							# reset %edi
	xor %ecx, %ecx
set_ones:
	cmp $0, %ebx							# if %ebx is 0 go
	je execute_evolutions			# to execute_evolution
	mov (%ebp, %edi, 4), %eax	# else move the first coord into %eax
	mov 4(%ebp, %edi, 4), %ecx	# the second one into %ecx
	inc %eax										# this is for padding
	push %ebx
	inc %ecx										# this is for padding
	inc %edi										#inc %edi twice to get the next pair of coordinates
	inc %edi
	xor %edx, %edx
	mov m, %ebx
	add $2, %ebx
	mul %ebx
	pop %ebx
	add %ecx, %eax							# y * m + x
	movl $1, (%esi, %eax, 4)			# set to one
	dec %ebx										# one less set of coordinates
	jmp set_ones								# loop
execute_evolutions:						# 
	mov (%ebp, %edi, 4), %edx		# moves the last element in the list into %edx
	mov %edx, k									# that element has the value of k		
	mov 4(%ebp, %edi, 4), %edx

	mov %edx, mode
	lea matrix, %ebp						# load address of matrix into ebp
	mov k, %edi
execute_evolution:
	cmpl $0, %edi									  # if k is 0 there are no evolutions left
	je modify_message 						# then print the matrix
	decl %edi												# decrement k
	xor %eax, %eax							# reset eax
change_row:
	inc %eax										# the index starts at 1 because at 0 we have the padding
	cmp n, %eax									# compare n to the index
	jg copy_matrix							# if the index is greater, we are done, move the values in the copy to the actual matrix
	xor %ebx, %ebx								# reset %ebx							
change_column:
	inc %ebx										# the index starts at 1 because at 0 we have the padding
	cmp m, %ebx									# compare m to the index
	jg change_row								# if the index is greater, we are done on this row
traverse_neighbors:
	xor %edx, %edx							# reset %edx
	push %eax										# push %eax to the stack because we'll be using it for other things for now
	push %ebx										# push %ebx to the stack because we'll be using it for other things for now
	dec %eax										# decrement eax because we start at row y - 1 where y is the row number of the current element
	mov m, %ebx
	add $2, %ebx
	mul %ebx												# multiply by m to get the index in the sequential list
	pop %ebx
	add %ebx, %eax							# add column index to get the proper element
	push %ebx
	mov m, %ebx
	add $2, %ebx
	dec %eax										# decrement to start in the corner
	add (%ebp, %eax, 4), %edx			# compare the element in the corner to 1
	inc %eax										# get the next element on the row
	add (%ebp, %eax, 4), %edx			# compare it to 1
	inc %eax										# next element on the row
	add (%ebp, %eax, 4), %edx			# compare to 1
	add %ebx, %eax									# get the next row, but start at the end
	add (%ebp, %eax, 4), %edx			# compare to 1
	dec %eax										# get the element before now
	dec %eax										# element from before
	add (%ebp, %eax, 4), %edx			# compare
	add %ebx, %eax									# get to the next row, this time from the beginning
	add (%ebp, %eax, 4), %edx			# compare
	inc %eax										# get to the next element on the row
	add (%ebp, %eax, 4), %edx			# compare
	inc %eax										# next element
	add (%ebp, %eax, 4), %edx			# compare
	sub %ebx, %eax									# get to the middle row
	dec %eax										# middle column, where the current element is
	cmpl $1, (%ebp, %eax, 4)
	je is_alive
	cmp $3, %edx # cell should be alive
	je alive
	jmp dead		# otherwise it's dead
is_alive:
	cmp $3, %edx
	je alive
	cmp $2, %edx
	je alive
	jmp dead
alive:
	movl $1, 1600(%ebp, %eax, 4) # move $1, into the copy, at the index of the current one
	pop %ebx										# get %ebx back
	pop %eax										# get %eax back
	jmp change_column						# go to the next element
dead:
	movl $0, 1600(%ebp, %eax, 4)	# move $0, into the copy, at the index of the current one
	pop %ebx										# get %ebx back
	pop %eax										# get %eax back
	jmp change_column						# go to the next element
copy_matrix:					# get the values from matrix_copy into matrix
	xor %edx, %edx
	mov n, %eax					
	mov m, %ebx
	inc %eax
	inc %eax
	inc %ebx
	inc %ebx
	mul %ebx						# stores into %eax the number of elements we need to go through
	mov $0, %ebx				# index of current element
copy_matrix_loop:	
	cmp %ebx, %eax			# if is at end
	je execute_evolution	# execute next_evolution
	movb 1600(%ebp, %ebx, 4), %dl
	movb %dl, (%ebp, %ebx, 4) # else, move the value of copy into the original
	mov $0, 1600(%ebp, %ebx, 4)
	inc %ebx																	# go to the next element
	jmp copy_matrix_loop											# repeat
modify_program:
	lea message, %ebp
	lea bitset, %esi
	mov $8, %esp
	xor %edi, %edi
	xor %ebx, %ebx
	xor %eax, %eax
	xor %edx, %edx
	cmp $1, mode
	je encrypt_message
	inc %edi
	inc %edi				# skip the first 2 chars: the '0x' part
decrypt_message:
	mov (%ebp, %edi, 4), %eax
	mov $4, %esp
	cmp $0, %eax
	je xor_operation
	cmp $10, %eax
	je xor_operation
	cmp $3, %eax
	je xor_operation
	sub $48, %eax
hexadecimal_to_binary:
	cmp $0, %esp
	je next_char
	xor %edx, %edx
	div $2
	mov %edx, (%esi, %ebx, 4)
	inc %ebx
	dec %esp
	jmp hexadecimal_to_binary
encrypt_message:
	cmp $0, (%ebp, %edi, 4)
	je xor_operation
	cmp $10, (%ebp, %edi, 4)
	je xor_operation
	cmp $3, (%ebp, %edi, 4)
	je xor_operation
ascii_to_binary:
	cmp $0, %esp
	je next_char
	xor %edx, %edx
	div $2
	mov %edx, (%esi, %ebx, 4)
	inc %ebx
	dec %esp
	jmp ascii_to_binary
next_char:
	mov $8, %esp
	inc %edi
	cmp $1, mode
	je encrypt_message
xor_operation:
	mov $2, (%esi, %edx, 4)
	xor %edx, %edx
	mov m, %eax
	mov n, %ebx
	inc %eax
	inc %eax
	inc %ebx
	inc %ebx
	mul %ebx
	mov %eax, %esp
	lea %ebp, bitset
	lea %ecx, matrix
	lea %edx, output
	xor %edi, %edi
	xor %esi, %esi
do_operation:
	cmp $2, (%ebp, %edi, 4)
	je print_output
	cmp %esi, %esp
	je reset_esi
jump_back:
	mov (%ebp, %edi, 4), %eax
	mov (%ecx, %esi, 4), %ebx
	xor %ebx, %eax
	mov %eax, (%edx, %edi, 4)
	inc %edi
reset_esi:
	xor %esi, %esi
	jmp jump_back
print_output:
	mov %edi, %ecx
	xor %edi, %edi
	xor %esi, %esi
	lea output2, %ebp
	lea output, %esp
	cmp $1, mode
	je print_encrypted
print_decrypted:	
loop_ascii:
	cmp %ecx, %edi
	je end_program
	mov %eax, (%ebp, %edi, 4)
	inc %edi
bits_to_ascii:
	xor %edx, %edx
	xor %eax, %eax
	add (%esp, %esi, 4), %eax
	inc %esi
	shl $1, %eax
	add (%esp, %esi, 4), %eax
	inc %esi
	shl $1, %eax
	add (%esp, %esi, 4), %eax
	inc %esi
	shl $1, %eax
	add (%esp, %esi, 4), %eax
	inc %esi
	shl $1, %eax
	add (%esp, %esi, 4), %eax
	inc %esi
	shl $1, %eax
	add (%esp, %esi, 4), %eax
	inc %esi
	shl $1, %eax
	add (%esp, %esi, 4), %eax
	inc %esi
	shl $1, %eax
	add (%esp, %esi, 4), %eax
	inc %esi
jmp loop_ascii:
print_encrypted:
	add $2, %ecx
	mov $48, (%ebp, %edi, 4)
	inc %edi
	mov $120, (%ebp, %edi, 4)
	inc %edi
loop_hex:
	cmp %ecx, %edi
	je end_program
	cmp %eax, $9
	jle print_integer
	jmp print_letter
set_hex:
	mov %eax, (%ebp, %edi, 4)
	inc %edi
calc_hex:
	xor %edx, %edx
	xor %eax, %eax
	add (%esp, %esi, 4), %eax
	inc %esi
	shl $1, %eax
	add (%esp, %esi, 4), %eax
	inc %esi
	shl $1, %eax
	add (%esp, %esi, 4), %eax
	inc %esi
	shl $1, %eax
	add (%esp, %esi, 4), %eax
	inc %esi
	jmp loop_hex
print_integer:
	add $48, %eax
	jmp set_hex
print_letter:
	sub $10, %eax
	add $97, %eax
	jmp set_hex
end_program:																# end of program
	mov $4, %eax
	mov $1, %ebx
	lea output, %ecx
	mov $1600, %edx
	int $0x80

	mov $1, %eax
	xor %ebx, %ebx
	int $0x80
