bits 32

section .text

extern kmain
global start
start:
	mov		esp, stack_top
	mov		ebp, esp
	call	kmain

section .stack
	
stack_bottom:
times		0x4000	db	0x00
stack_top: