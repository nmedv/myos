bits 16

extern enable_a20
extern println

section .text

krldr:
	mov		si, krldr_str
	call	println
	
	call	enable_a20			; Enable A20 line
	cmp		al, 0x01
	jne		a20_err				; Error (if AL is not 1)

	mov		si, kr_dap			; Load kernel from disk (read next 64 sectors
	mov		dl, [drv_num]		; from drive to 0x10000)
	mov		ah, 0x42
	int		0x13
	jc		drv_load_err		; Error (if CF is 1)
	
	lgdt	[gdtr]				; Setup GDT and IDT
	lidt	[idtr]
	
	mov		eax, cr0 
	or		al, 1				; set PE bit in CR0 register
	mov		cr0, eax
	
	jmp		0x08:flush			; Reload CS
	
flush:
	mov		ax, 0x10			; Reload remain segment registers
	mov		ds, ax
	mov		es, ax
	mov		fs, ax
	mov		gs, ax
	mov		ss, ax
	jmp		dword entry32		; Jump to 32-bit mode

bits 32

entry32:
	; todo: add code to find entry in ELF file
	jmp		0x10060				; Jump to kernel

bits 16

a20_err:
	mov		si, a20_err_str
	call	println
	jmp		$

drv_load_err:
	mov		si, disk_err_str
	call	println
	jmp		$


section .data

a20_err_str		db	"ERROR: CAN'T ENABLE A20 LINE", 0x00
disk_err_str	db	"DISK ERROR!", 0x00
krldr_str		db	"KERNEL LOAD", 0x00
drv_num			db	0x80

; Flat 32-bit mode segment descriptors
gdt_start:
sd_null			dq	0x00
sd_kr_code		db	0xff, 0xff, 0x00, 0x00, 0x00, 0x9a, 0xcf, 0x00
sd_kr_data		db	0xff, 0xff, 0x00, 0x00, 0x00, 0x92, 0xcf, 0x00
gdt_end:
gdtr			dw	gdt_end - gdt_start
				dd	gdt_start
idtr			dw	0x00
				dd	0x00

; Kernel DAP
kr_dap			dw	0x1000
				dw	0x0040
				dw	0x0000
				dw	0x1000
				dq	0x41
