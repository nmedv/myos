bits 16

global print
global println

section .text

; Print string
;  SI - pointer to 0-teminated string
print:
	mov		ah, 0x0e
	xor		bh, bh
	lodsb
	cmp		al, 0
	je		print_end
	int		0x10
	jmp		print
print_end:
	ret
	
; Print string with line end
;  SI - pointer to 0-teminated string
println:
	call	print
	mov		si, crlf
	call	print
	ret
	
crlf		db	0x0d, 0x0a, 0x00