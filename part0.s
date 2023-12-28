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
	lea n, %ecx
	mov $1024, %edx
	int $0x80

	mov $2, %edi
	movb (%ecx, %edi, 1), %al
	sub $51, %eax
	/*
get_values:
	cmp $0, %esi
	je initialize_list
	dec %esi
	lea arguments, %edi

	lea (%edi, %esi, 1), %ebx
	int $0x80

	cmp $0, %esi
	jne read_arguments

	lea k, %ebx
	int $0x80
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
