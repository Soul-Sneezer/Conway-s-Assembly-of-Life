.data
arguments: .space 1024
n: .space 1
m: .space 1
p: .space 1
k: .space 1
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
	xor %ebx, %ebx						# reset ebx
	xor %edi, %edi						# reset edi

parse_values: # the last char is a line feed(ascii value 10)
							# space is 32
	mov (%ecx, %edi, 1), %esi
	cmp $0, %esi							# compare the argument[%edi] to 10(value for line feed), if true jump
	je initialize_matrix			# to initialize matrix
	cmp $10, %esi							# compare the argument[%edi] to 32(value for whitespace), if true jump
	je found_whitespace				# to found_whitespace
char_to_value:							# convert from char to a digit
	movb (%ecx, %edi, 1), %dl	# move byte from argument[%edi], to %dl
	sub $48, %edx							# subtract 48(value of '0' in ascii) to get the digit
	mov $10, %esi
	mul %esi										# shift eax to the right(in decimal) and add the new digit
	add %edx, %eax
found_whitespace:
	mov %eax, (%ebp, %ebx, 1) # move the value from eax back to the variable
	xor %eax, %eax							# reset value in eax
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
