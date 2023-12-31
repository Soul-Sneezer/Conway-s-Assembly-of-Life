.data
arguments: .space 1024
n: .space 4
m: .space 4
p: .space 4
list: .space 2048
k: .space 4
matrix: .space 1600
matrix_copy: .space 1600
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
create_matrix:
	mov n, %eax
	mul m											# get number of elements in matrix
	lea matrix_copy, %ecx
	lea matrix, %ebp					# get address of matrix
initialize_matrix:
	dec %eax									# start from the end of the matrix(easier this way)
	mov $0, (%ecx, %eax, 4)
	mov $0, (%ebp, %eax, 4)		# set value at index %eax to 0
	cmp $0, %eax							# if eax is 0 stop loop
	jne initialize_matrix			# else continue
	lea list, %ebp						# get list of coordinates
	lea matrix, %esi					# get matrix
	mov p, %ebx								# get p(number of coordinates) into %ebx
	mov $0, %edi							# reset %edi
set_ones:
	cmp $0, %ebx							# if %ebx is 0 go
	je execute_evolutions			# to execute_evolution
	mov (%ebp, %edi, 4), %eax	# else move the first coord into %eax
	mov 4(%ebp, %edi, 4), %ecx	# the second one into %ecx
	inc %eax										# this is for padding
	inc %ecx										# this is for padding
	inc %edi										#inc %edi twice to get the next pair of coordinates
	inc %edi
	mul m												# mul row number by elements per row to get the proper index
	add %ecx, %eax							# y * m + x
	mov $1, (%esi, %eax, 4)			# set to one
	dec %ebx										# one less set of coordinates
	jmp set_ones								# loop
execute_evolutions:						# 
	mov (%ebp, %edi, 4), %edx
	mov %edx, k
	lea matrix, %ebp
#	lea matrix_copy, might not be necessary :o
execute_evolution:
	cmp $0, k
	je print_matrix 
	mov $1, %ecx
	mov $1, %ebx
	mov $0, %eax
	mov m, %ecx
	inc %ecx
	mov n, %edx
	inc %edx
change_row:
	inc %eax
	cmp n, %eax
	jg copy_matrix
	mov $0, %ebx
change_column:
	inc %ebx
	cmp m, %ebx
	jg change_row
traverse_neighbors:
	xor %edx, %edx
	push %eax
	push %ebx
	dec %eax
	mul m
	add %ebx, %eax
	dec %eax
	cmp (%ebp, %eax, 4), $1
	je increment_edx1
jump_back1:
	inc %eax
	cmp (%ebp, %eax, 4), $1
	je increment_edx2
jump_back2:
	inc %eax
	cmp (%ebp, %eax, 4), $1
	je increment_edx3
jump_back3:
	add m, %eax
	cmp (%ebx, %eax, 4), $1
	je increment_edx4
jump_back4:
	dec %eax
	cmp (%ebx, %eax, 4), $1
	je increment_edx5
jump_back5:
	dec %eax
	cmp (%ebx, %eax, 4), $1
	je increment_edx6
jump_back6:
	add m, %eax
	cmp (%ebx, %eax, 4), $1
	je increment_edx7
jump_back7:
	inc %eax
	cmp (%ebx, %eax, 4), $1
	je increment_edx8
jump_back8:
	inc %eax
	cmp (%ebx, %eax, 4), $1
	je increment_edx9
jump_back9:
	sub m, %eax
	dec %eax
	cmp %esi, 3 # cell should be alive
	je alive
	cmp %esi, 2	# cell should be dead :0
	je alive
	jmp dead
alive:
	mov $1, 1600(%ebp, %eax, 4)
	pop %ebx
	pop %eax
	jmp change_column
dead:
	mov $0, 1600(%ebp, %eax, 4)
	pop %ebx
	pop %eax
	jmp change_column
increment_edx1:
	inc %esi
	jmp jump_back1
increment_edx2:
	inc %esi
	jmp jump_back2
increment_edx3:
	inc %esi
	jmp jump_back3
increment_edx4:
	inc %esi
	jmp jump_back4
increment_edx5:
	inc %esi
	jmp jump_back5
increment_edx6:
	inc %esi
	jmp jump_back6
increment_edx7:
	inc %esi
	jmp jump_back7
increment_edx8:
	inc %esi
	jmp jump_back8
increment_edx9:
	inc %esi
	jmp jump_back9
copy_matrix:
	mov n, %eax
	mov m, %ebx
	inc %eax
	inc %ebx
	mul %ebx
	mov $0, %ebx
	cmp %ebx, %eax
	je execute_evolution
	mov 1600(%ebp, %eax, 4), (%ebp, %eax, 4)
	inc %ebx
	jmp copy_matrix
print_matrix:
value_to_char:
	mov $2, %ebx/*	
print_arguments:
	mov $4, %eax
	mov $1, %ebx
	lea arguments, %ecx
	mov $1600, %edx
	int $0x80
	*/
end_program:
	mov $1, %eax
	xor %ebx, %ebx
	int $0x80
