.data
arguments: .space 1024
n: .space 1
m: .space 1
p: .space 1
list: .space 512
k: .space 1
matrix: .space 400
matrix_copy: .space 400
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
	mov %al, (%ebp, %ebx, 1) 	# move the value from eax back to the variable
	xor %eax, %eax						# reset value in eax
	inc %edi									# get to next char
	inc %ebx									# go to the next variable byte	
	jmp parse_values					# loop
create_matrix:
	mov n, %eax
	mul m
initialize_matrix:
	dec %eax
	lea matrix, %edi
	mov $0, (%edi, %eax, 4)
	cmp $0, %eax
	jne initialize_matrix
/*
execute_evolution:

print_matrix:
value_to_char:
print_arguments:
	mov $0, %esi
	mov $4, %eax
	mov $1, %ebx
	lea arguments, %ecx
	mov $1024, %edx
	int $0x80
*/
end_program:
	mov $1, %eax
	xor %ebx, %ebx
	int $0x80
