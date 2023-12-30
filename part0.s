.data
arguments: .space 1024
n: .space 4
m: .space 4
p: .space 4
k: .space 4
matrix: .space 400
.text
.global main
main:

read_input:
	mov $3, %eax				# argument for read
	xor %ebx, %ebx			# read from stdin
	lea arguments, %ecx	# into buffer named arguments
	mov $1024, %edx			# max size of buffer is 1024 bytes
	int $0x80						# syscall

	lea n, %ebp									# the variables are sequential in memory(I believe), so I get the address of the first one
	xor %eax, %eax						# reset eax
	xor %edi, %edi						# reset edi
	xor %edx, %edx

parse_values:
	xor %edx, %edx
	movb (%ecx, %edi, 1), %dl
	cmp $0, %dl							# compare the argument[%edi] to 0(null), if true jump
	je initialize_matrix			# to initialize matrix
	cmp $3, %dl
	je initialize_matrix
	cmp $10, %dl							# compare the argument[%edi] to 10(value line feed), if true jump
	je found_whitespace
	cmp $32, %dl
	je found_whitespace				# to found_whitespace
char_to_value:							# convert from char to a digit
	mov $10, %edx
	mul %edx
	xor %edx, %edx
	movb (%ecx, %edi, 1), %dl
	sub $48, %dl							# subtract 48(value of '0' in ascii) to get the digit
	add %dl, %al
	inc %edi
	jmp parse_values
found_whitespace:
	mov %al, (%ebp, %ebx, 4) # move the value from eax back to the variable
	xor %eax, %eax						# reset value in eax
	inc %edi
	inc %ebx									# go to the next variable byte	
	jmp parse_values					# loop
initialize_matrix:
/*
	mov n, %eax
	mul m
	dec %eax
	mov %eax, %ecx
	lea list, %edi
	mov $0, (%edi, %ecx, 1)
	cmp $0, %ecx
	je print_list
	dec %ecx
	jmp initialize_list

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
