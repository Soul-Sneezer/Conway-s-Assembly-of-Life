.data
n: .space 1
m: .space 1
p: .space 1
k: .space 1
arguments: .space 1024
matrix: .space 400
.text
.global main
main:

read_input:
	mov $3, %eax
	xor %ebx, %ebx
	lea arguments, %ecx
	mov $1024, %edx
	int $0x80

	//mov $28, %edi
	//movb (%ecx, %edi, 1), %al
parse_values: // the last char is a line feed(ascii value 10)
							// space is 32
	lea n, %ebp
	mov $0, %ebx
	mov $0, %edi
	cmp $10, (%ecx, %edi, 1)
	je initialize_matrix
	cmp $32, (%ecx, %edi, 1)
	je found_whitespace
char_to_value:
	movb (%ecx, %edi, 1), %dl
	sub $48, %edx
	mov (%ebp, %ebx, 1), %eax
	mul $10, %eax
	add %edx, %eax
	mov %eax, (%ebp, %ebx, 1)
found_whitespace:
	inc %ebx	
	jmp parse_values
/*
initialize_matrix:
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
	dec %esi
	mov $4, %eax
	mov $1, %ebx
	mov (%edi, %esi, 1), %ecx
	mov $1, %edx
	int $0x80
	cmp $0, %esi
	jne print_list
	*/
end_program:
	mov $1, %eax
	xor %ebx, %ebx
	int $0x80
