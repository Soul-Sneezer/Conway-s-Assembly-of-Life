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
	mov (%ebp, %edi, 4), %edx		# moves the last element in the list into %edx
	mov %edx, k									# that element has the value of k		
	lea matrix, %ebp						# load address of matrix into ebp
#	lea matrix_copy, might not be necessary :o
execute_evolution:
	cmp $0, k									  # if k is 0 there are no evolutions left
	je print_matrix 						# then print the matrix
	dec k												# decrement k
	#mov $1, %ecx
	xor %eax, %eax							# reset eax
change_row:
	inc %eax										# the index starts at 1 because at 0 we have the padding
	cmp n, %eax									# compare n to the index
	jg copy_matrix							# if the index is greater, we are done, move the values in the copy to the actual matrix
	mov $0, %ebx								# reset %ebx							
change_column:
	inc %ebx										# the index starts at 1 because at 0 we have the padding
	cmp m, %ebx									# compare m to the index
	jg change_row								# if the index is greater, we are done on this row
traverse_neighbors:
	xor %edx, %edx							# reset %edx
	push %eax										# push %eax to the stack because we'll be using it for other things for now
	push %ebx										# push %ebx to the stack because we'll be using it for other things for now
	dec %eax										# decrement eax because we start at row y - 1 where y is the row number of the current element
	mul m												# multiply by m to get the index in the sequential list
	add %ebx, %eax							# add column index to get the proper element
	dec %eax										# decrement to start in the corner
	cmp $1, (%ebp, %eax, 4)			# compare the element in the corner to 1
	je increment_edx1						# if it's 1, increment %edx
jump_back1:										# this is where we jump back from increment_edx1
	inc %eax										# get the next element on the row
	cmp $1, (%ebp, %eax, 4)			# compare it to 1
	je increment_edx2						# if 1, increment $edx
jump_back2:										# jump back from increment_edx2
	inc %eax										# next element on the row
	cmp $1, (%ebp, %eax, 4)			# compare to 1
	je increment_edx3						# if 1, increment
jump_back3:										# jump back
	add m, %eax									# get the next row, but start at the end
	cmp $1, (%ebp, %eax, 4)			# compare to 1
	je increment_edx4						# if 1, increment
jump_back4:										# jump back
	dec %eax										# get the element before now
	cmp $1, (%ebp, %eax, 4)			# compare
	je increment_edx5						# increment
jump_back5:										# jump back
	dec %eax										# element from before
	cmp $1, (%ebp, %eax, 4)			# compare
	je increment_edx6						# increment
jump_back6:										# jump back
	add m, %eax									# get to the next row, this time from the beginning
	cmp $1, (%ebp, %eax, 4)			# compare
	je increment_edx7						# increment
jump_back7:										# jump
	inc %eax										# get to the next element on the row
	cmp $1, (%ebp, %eax, 4)			# compare
	je increment_edx8						# increment
jump_back8:										# jump
	inc %eax										# next element
	cmp $1, (%ebp, %eax, 4)			# compare
	je increment_edx9						# increment
jump_back9:										# jump back
	sub m, %eax									# get to the middle row
	dec %eax										# middle column, where the current element is
	cmp $3, %edx # cell should be alive
	je alive
	cmp $2, %edx	# cell should be alive :0
	je alive
	jmp dead		# otherwise it's dead
alive:
	mov $1, 1600(%ebp, %eax, 4) # move $1, into the copy, at the index of the current one
	pop %ebx										# get %ebx back
	pop %eax										# get %eax back
	jmp change_column						# go to the next element
dead:
	mov $0, 1600(%ebp, %eax, 4)	# move $0, into the copy, at the index of the current one
	pop %ebx										# get %ebx back
	pop %eax										# get %eax back
	jmp change_column						# go to the next element
increment_edx1:
	inc %edx
	jmp jump_back1
increment_edx2:
	inc %edx
	jmp jump_back2
increment_edx3:
	inc %edx
	jmp jump_back3
increment_edx4:
	inc %edx
	jmp jump_back4
increment_edx5:
	inc %edx
	jmp jump_back5
increment_edx6:
	inc %edx
	jmp jump_back6
increment_edx7:
	inc %edx
	jmp jump_back7
increment_edx8:
	inc %edx
	jmp jump_back8
increment_edx9:
	inc %edx
	jmp jump_back9
copy_matrix:					# get the values from matrix_copy into matrix
	mov n, %eax					
	mov m, %ebx
	inc %eax
	inc %ebx
	mul %ebx						# stores into %eax the number of elements we need to go through
	mov $0, %ebx				# index of current element
copy_matrix_loop:	
	cmp %ebx, %eax			# if is at end
	je execute_evolution	# execute next_evolution
	mov 1600(%ebp, %eax, 4), %edx
	movl %edx, (%ebp, %eax, 4) # else, move the value of copy into the original
	inc %ebx																	# go to the next element
	jmp copy_matrix_loop											# repeat
print_matrix:																# this will be the part where I print the final matrix
value_to_char:															# this converts from an integer byte to a char
end_program:																# end of program
	mov $1, %eax
	xor %ebx, %ebx
	int $0x80
