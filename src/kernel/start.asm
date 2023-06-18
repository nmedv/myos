bits 32

extern kmain

global start

section .text

start:
	mov		esp, stack
	mov		ebp, esp
	call	kmain

section .stack
stack_begin:
times		0x4000	db	0x00
stack: