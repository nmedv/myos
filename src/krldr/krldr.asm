bits 16

org 0x7f00

start:
	mov		si, krldr_str
	call	print
	call	enable_a20

krldr:
	mov		si, kr_dap
	mov		dl, [drv_num]	; Read next 64 sectors from drive
	mov		ah, 0x42
	int		0x13
	jc		drv_load_error	; Error (if CF is 1)
	
	jmp		dword 0x00:0x10054	; Jump to 32-bit kernel
								; 0x54 - ELF32 header size

drv_load_error:
	mov		si, disk_err_str
	call	print
	jmp		$

; Print character
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


; Enable A20 line
enable_a20:
	call	check_a20
	cmp		al, 0x01
	je		enable_a20_end
	; todo: add code to enable a20 line!!!
	jmp		$

enable_a20_err:
	mov		si, a20_err_str
	call	print
	ret
	
enable_a20_end:
	mov		si, a20_en_str
	call	print
	ret

; Wait for keyboard output (bit 0)
enable_a20wait0:
	in		al, 0x64
	test	al, 1
	jz		enable_a20wait0
	ret

; Wait for keyboard input (bit 1)
enable_a20wait1:
	in		al, 0x64
	test	al, 2
	jnz		enable_a20wait1
	ret
	
; Check if A20 line is enabled already
;  AX (out): 0 - disabled, 1 - enabled
check_a20:
	pushf
	push	si
	push	di
	push	ds
	push	es
	cli
	
	mov ax, 0x0000
	mov ds, ax
	mov si, 0x0500	;	0x0000:0x0500(0x00000500) -> ds:si
	not ax
	mov es, ax
	mov di, 0x0510	;	0xffff:0x0510(0x00100500) -> es:di
	
	mov al, [ds:si]					; save old values
	mov byte [buffer_belowMB], al
	mov al, [es:di]
	mov byte [buffer_overMB], al
	
	mov ah, 1
	mov byte [ds:si], 0
	mov byte [es:di], 1
	mov al, [ds:si]
	cmp al, [es:di]		; check byte at address 0x0500 != byte
	jne check_a20_end	; at address 0x100500
	dec ah
check_a20_end:
	mov al, [buffer_belowMB]	; restore old values
	mov [ds:si], al
	mov al, [buffer_overMB]
	mov [es:di], al
	shr ax, 8			; move result from ah to al register and clear ah
	
	sti
	pop	es
	pop	ds
	pop	di
	pop	si
	popf
	ret


; Data
disk_err_str	db	'DISK ERROR!', 0x0d, 0x0a, 0x00
krldr_str		db	'KERNEL LOAD', 0x0d, 0x0a, 0x00
a20_en_str		db	'A20 LINE IS ENABLED', 0x0d, 0x0a, 0x00
a20_err_str		db	"ERROR: CAN'T ENABLE A20 LINE", 0x0d, 0x0a, 0x00
buffer_belowMB	db	0
buffer_overMB	db	0
drv_num			db	0x80

; Kernel DAP
kr_dap			dw	0x1000
				dw	0x0040	; Number of sectors to be read
				dw	0x0000	; Segment offset
				dw	0x1000	; Segment
				dq	0x41	; Absolute number of the start of the sectors to be read
