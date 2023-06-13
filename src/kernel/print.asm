bits 32

global print

section .text

; void print(char* string)
print:
	mov		esi, [esp + 4]
	
print_loop:
	mov		ah, 0xe
	xor		bh, bh
	lodsb
	cmp		al, 0
	je		print_end
	int		0x10
	jmp		print_loop

print_end:
	ret