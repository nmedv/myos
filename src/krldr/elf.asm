bits 32

; Find the entry point in the ELF file
;  EDI - pointer to the beginning of the ELF data
;  
elf_entry:
	mov		eax, dword cs:[edi]
	cmp		eax, dword [elf_sig]
	jne		elf_err1
	
	add		edi, 0x04
	mov		eax, cs:[edi]
	
elf_err1:
	mov		eax, 0x01	; ELF signature mismatch
	jmp		elf_end
	
elf_end:
	ret
	
elf_sig		dd	0x7f454c46