.data
arguments: .space 1024
n: .space 4
m: .space 4
p: .space 4
x: .space 4
y: .space 4
list: .space 2048
k: .space 4
mode: .space 4
message: .space 100
bitset: .space 800
matrix: .space 1600
matrix_copy: .space 1600
output: .space 3200
output2: .space 3200
formatscan: .asciz "%d"
formatscan2: .asciz "%s"
formatprint: .asciz "%c"
formatprint2: .asciz "%s\n"
size: .space 4
.text
.global main
main:


read_input:
	push $n
	push $formatscan
	call scanf
	pop %ebx
	pop %ebx

	push $m
	push $formatscan
	call scanf
	pop %ebx
	pop %ebx

	push $p
	push $formatscan
	call scanf
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
	call scanf
	pop %ebx
	pop %ebx
	
	mov x, %eax
	mov %eax, (%ebp, %edi, 4)
	inc %edi

	push $y
	push $formatscan
	call scanf
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
	call scanf
	pop %ebx
	pop %ebx

	push $mode
	push $formatscan
	call scanf
	pop %ebx
	pop %ebx

	push $message
	push $formatscan2
	call scanf
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
	lea matrix, %edx					# get matrix
	mov p, %ebx								# get p(number of coordinates) into %ebx
	xor %edi, %edi							# reset %edi
	xor %ecx, %ecx
set_ones:
	cmp $0, %ebx							# if %ebx is 0 go
	je execute_evolutions			# to execute_evolution
	mov (%ebp, %edi, 4), %eax	# else move the first coord into %eax
	mov 4(%ebp, %edi, 4), %ecx	# the second one into %ecx
	inc %eax										# this is for padding
	push %edx
	push %ebx
	inc %ecx										# this is for padding
	inc %edi										#inc %edi twice to get the next pair of coordinates
	inc %edi
	xor %edx, %edx
	mov m, %ebx
	add $2, %ebx
	mul %ebx
	pop %ebx
	pop %edx
	add %ecx, %eax							# y * m + x
	movl $1, (%edx, %eax, 4)			# set to one
	dec %ebx										# one less set of coordinates
	jmp set_ones								# loop
execute_evolutions:						# 
	lea matrix, %ebp						# load address of matrix into ebp
	mov k, %edi
execute_evolution:
	cmpl $0, %edi									  # if k is 0 there are no evolutions left
	je modify_program 						# then print the matrix
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
	lea bitset, %ecx
	xor %edi, %edi
	xor %ebx, %ebx
	xor %eax, %eax
	xor %edx, %edx
	cmp $0, mode
	je encrypt_message
	inc %edi
	inc %edi				# skip the first 2 chars: the '0x' part
decrypt_message:
	movb (%ebp, %edi, 1), %al
	cmp $0, %eax
	je xor_operation
	cmp $10, %eax
	je xor_operation
	cmp $3, %eax
	je xor_operation
hex_to_decimal:
	cmp $65, %eax
	jae letter_to_decimal
	sub $48, %eax
jump_back2:
	mov %eax, %edx
	shr $1, %eax
	shl $1, %eax
	sub %eax, %edx
	shr $1, %eax
	mov %edx, 12(%ecx, %ebx, 4)

	mov %eax, %edx
	shr $1, %eax
	shl $1, %eax
	sub %eax, %edx
	shr $1, %eax
	mov %edx, 8(%ecx, %ebx, 4)

	mov %eax, %edx
	shr $1, %eax
	shl $1, %eax
	sub %eax, %edx
	shr $1, %eax
	mov %edx, 4(%ecx, %ebx, 4)

	mov %eax, %edx
	shr $1, %eax
	shl $1, %eax
	sub %eax, %edx
	shr $1, %eax
	mov %edx, 0(%ecx, %ebx, 4)

	inc %edi
	add $4, %ebx

	jmp decrypt_message
letter_to_decimal:
	sub $55, %eax
	jmp jump_back2
encrypt_message:
	xor %eax, %eax
	movb (%ebp, %edi, 1), %al
	cmp $0, %eax
	je xor_operation
	cmp $10, %eax
	je xor_operation
	cmp $3, %eax
	je xor_operation
ascii_to_binary:
	mov %eax, %edx
	shr $1, %eax
	shl $1, %eax
	sub %eax, %edx
	shr $1, %eax
	mov %edx, 28(%ecx, %ebx, 4)

	mov %eax, %edx
	shr $1, %eax
	shl $1, %eax
	sub %eax, %edx
	shr $1, %eax
	mov %edx, 24(%ecx, %ebx, 4)

	mov %eax, %edx
	shr $1, %eax
	shl $1, %eax
	sub %eax, %edx
	shr $1, %eax
	mov %edx, 20(%ecx, %ebx, 4)

	mov %eax, %edx
	shr $1, %eax
	shl $1, %eax
	sub %eax, %edx
	shr $1, %eax
	mov %edx, 16(%ecx, %ebx, 4)

	mov %eax, %edx
	shr $1, %eax
	shl $1, %eax
	sub %eax, %edx
	shr $1, %eax
	mov %edx, 12(%ecx, %ebx, 4)

	mov %eax, %edx
	shr $1, %eax
	shl $1, %eax
	sub %eax, %edx
	shr $1, %eax
	mov %edx, 8(%ecx, %ebx, 4)

	mov %eax, %edx
	shr $1, %eax
	shl $1, %eax
	sub %eax, %edx
	shr $1, %eax
	mov %edx, 4(%ecx, %ebx, 4)

	mov %eax, %edx
	shr $1, %eax
	shl $1, %eax
	sub %eax, %edx
	shr $1, %eax

	mov %edx, 0(%ecx, %ebx, 4)

	inc %edi
	add $8, %ebx
	jmp encrypt_message
xor_operation:
	mov $2, (%ecx, %ebx, 4)
	xor %edx, %edx
	mov m, %eax
	mov n, %ebx
	inc %eax
	inc %eax
	inc %ebx
	inc %ebx
	mul %ebx
	mov %eax, size
	lea bitset, %ebp
	lea matrix, %ecx
	#lea output, %edx
	xor %edi, %edi
	xor %edx, %edx
do_operation:
	cmp $2, (%ebp, %edi, 4)
	je print_output
	cmp %edx, size
	je reset_edx
jump_back:
	mov (%ebp, %edi, 4), %eax
	mov (%ecx, %edx, 4), %ebx
	xor %ebx, %eax
	mov %eax, 3200(%ecx, %edi, 4)
	inc %edi
	inc %edx
	jmp do_operation
reset_edx:
	xor %edx, %edx
	jmp jump_back
print_output:
	mov %edi, %ecx
	xor %edi, %edi
	xor %esi, %esi
	lea output2, %ebp
	lea output, %ebx
	cmp $1, mode
	je print_encrypted
print_decrypted:
	shr $2, %ecx
	
	push %ecx
	push %ebx
	push $48
	push $formatprint
	call printf
	pop %edx
	pop %edx

	push $0
	call fflush
	pop %edx
	pop %ebx
	pop %ecx

	push %ecx
	push %ebx
	push $120
	push $formatprint
	call printf
	pop %edx
	pop %edx

	push $0
	call fflush
	pop %edx
	pop %ebx
	pop %ecx


	inc %edi
	inc %edi
	add $2, %ecx
bits_to_hex:
	cmp %ecx, %edi
	je end_program
	xor %edx, %edx
	xor %eax, %eax
	add (%ebx, %esi, 4), %eax
	inc %esi
	shl $1, %eax
	add (%ebx, %esi, 4), %eax
	inc %esi
	shl $1, %eax
	add (%ebx, %esi, 4), %eax
	inc %esi
	shl $1, %eax
	add (%ebx, %esi, 4), %eax
	inc %esi
	cmp $10, %eax
	jb print_integer
	jmp print_letter
jump_back1:
	mov %eax, (%ebp, %edi, 4)
	inc %edi
	jmp bits_to_hex
print_encrypted:
bits_to_ascii:
	cmp %ecx, %edi
	jge end_program
	xor %edx, %edx
	xor %eax, %eax
	add (%ebx, %edi, 4), %eax
	inc %edi
	shl $1, %eax
	add (%ebx, %edi, 4), %eax
	inc %edi
	shl $1, %eax
	add (%ebx, %edi, 4), %eax
	inc %edi
	shl $1, %eax
	add (%ebx, %edi, 4), %eax
	inc %edi
	shl $1, %eax
	add (%ebx, %edi, 4), %eax
	inc %edi
	shl $1, %eax
	add (%ebx, %edi, 4), %eax
	inc %edi
	shl $1, %eax
	add (%ebx, %edi, 4), %eax
	inc %edi
	shl $1, %eax
	add (%ebx, %edi, 4), %eax
	inc %edi

	push %edx
	push %ecx
	push %ebx
	push %eax
	push $formatprint
	call printf
	pop %eax
	pop %eax

	push $0
	call fflush
	pop %eax

	pop %ebx
	pop %ecx
	pop %edx
#	mov %eax, (%ebp, %edi, 4)
#	inc %edi
	jmp bits_to_ascii
print_integer:
	add $48, %eax
	push %ebx
	push %ecx
	push %eax
	push $formatprint
	call printf
	pop %edx
	pop %edx

	push $0
	call fflush
	pop %edx

	pop %ecx
	pop %ebx

	jmp jump_back1
print_letter:
	add $55, %eax
	push %ebx
	push %ecx
	push %eax
	push $formatprint
	call printf
	pop %edx
	pop %edx

	push $0
	call fflush
	pop %edx

	pop %ecx
	pop %ebx
	jmp jump_back1
end_program:			# end of program
	push $10
	push $formatprint
	call printf
	pop %eax
	pop %eax
	
	mov $1, %eax
	xor %ebx, %ebx
	int $0x80
