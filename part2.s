.data
arguments: .space 1024
n: .space 4
m: .space 4
p: .space 4
x: .space 4
y: .space 4
k: .space 4
list: .space 2048
formatscan: .asciz "%d"
formatprint: .asciz "%c "
formatprint2: .asciz "%c"
filename_in: .asciz "in.txt"
filename_out: .asciz "out.txt"
fd_in: .space 4
fd_out: .space 4
matrix: .space 1600
matrix_copy: .space 1600
output: .space 3200
.text
.global main
main:
read_input:
	push $filename_in
	call fopen
	pop %ebx
	mov %eax, fd_in

	push $filename_out
	call fopen
	pop %ebx
	mov %eax, fd_out

	push $n
	push $formatscan
	push $fd_in
	call fscanf
	pop %ebx
	pop %ebx
	pop %ebx

	push $m
	push $formatscan
	push $fd_in
	call fscanf
	pop %ebx
	pop %ebx
	pop %ebx

	push $p
	push $formatscan
	push $fd_in
	call fscanf
	pop %ebx
	pop %ebx
	pop %ebx

	xor %ecx, %ecx
	xor %eax, %eax
	lea list, %ebp
	xor %edi, %edi
read_ones:
	cmp p, %ecx
	je create_matrix

	push %ecx
	push $x
	push $formatscan
	push $fd_in
	call fscanf
	pop %ebx
	pop %ebx
	pop %ebx

	mov x, %eax
	mov %eax, (%ebp, %edi, 4)
	inc %edi


	push $y
	push $formatscan
	push $fd_in
	call fscanf
	pop %ebx
	pop %ebx
	pop %ebx

	pop %ecx

	mov y, %eax
	mov %eax, (%ebp, %edi, 4)
	inc %edi
	inc %ecx
	jmp read_ones
create_matrix:
	push $k
	push $formatscan
	push $fd_in
	call fscanf
	pop %ebx
	pop %ebx
	pop %ebx

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
	lea matrix, %ebp						# load address of matrix into ebp
execute_evolution:
	cmpl $0, k									  # if k is 0 there are no evolutions left
	je init_print_matrix 						# then print the matrix
	decl k												# decrement k
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
init_print_matrix:# this will be the part where I print the final matrix
	lea output, %ebp
	mov n, %eax
	inc %eax
	inc %eax
	mov m, %ecx
	inc %ecx
	inc %ecx
	mul %ecx
	lea matrix, %edx
	xor %ebx, %ebx
	mov %ecx, %ebx
	sub %ecx, %eax
	xor %edi, %edi
print_matrix:
	cmp %eax, %ebx
	je end_program
	push %edx
	push %eax
	mov %ebx, %eax
	inc %eax
	xor %edx, %edx
	idiv %ecx
	cmp $0, %edx
	je print_endline
	cmp $1, %edx
	je print_nothing
	pop %eax
	pop %edx
	push %eax
	push %edx
	push %ecx

value_to_char: # this converts from an integer byte to a char
	cmpl $1, (%edx, %ebx, 4)
	je print_one
	jmp print_zero
print_endline:
	push %ecx
	push %ebx
	push $10
	push $formatprint2
	push $fd_out
	call printf
	pop %ebp
	pop %ebp
	pop %ebp

	push $0
	call fflush
	pop %ebp

	pop %ebx
	pop %ecx
	pop %eax
	pop %edx

	jmp print_char
print_one:
	push %ebx
	push $49
	push $formatprint
	push $fd_out
	call fprintf
	pop %ebp
	pop %ebp
	pop %ebp

	push $0
	call fflush
	pop %ebp

	pop %ebx
	pop %ecx
	pop %edx
	pop %eax
	
	jmp print_char
print_zero:
	push %ebx
	push $48
	push $formatprint
	push $fd_out
	call fprintf
	pop %ebp
	pop %ebp
	pop %ebp

	push $0
	call fflush
	pop %ebp

	pop %ebx
	pop %ecx
	pop %edx
	pop %eax

	
	jmp print_char
print_nothing:
	pop %eax
	pop %edx
print_char:
	inc %ebx
	jmp print_matrix
end_program:																# end of program
	mov $1, %eax
	xor %ebx, %ebx
	int $0x80
