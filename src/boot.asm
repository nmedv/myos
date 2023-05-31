
;									MEMORY MAP
;
;
;				  Free (if A20 is enabled)
; 0xffff:0x0000 -----------------------------------------------------
;				  BIOS data, not free (? bytes)
; 0x9000:0xffff -----------------------------------------------------
;				  ????
; 0x0000:0xff00 -----------------------------------------------------
;				  Data loaded by the bootloader (32 KB, 64 sectors)
; 0x0000:0x7f00 -----------------------------------------------------
;				  Boot stack (256 bytes)
; 0x0000:0x7e00 -----------------------------------------------------
;				  Boot Sector (512 bytes)
; 0x0000:0x7c00 -----------------------------------------------------


bits 16

org 0x7c00

start:
	cli
	mov		ax, 0x07e0
	mov		ss, ax			; Stack > 0x7e00
	mov		sp, 0
	mov		bp, 0
	
	xor		ax, ax			; Set registers to zero
	mov		bx, ax
	mov		cx, ax
	mov		dx, ax
	mov		ds, ax
	mov		si, ax
	mov		es, ax
	mov		di, ax
	sti
	
	mov		ax, 3			; Switch to text mode 80x25
	int		0x10
	mov		ah, 0x2			; Cursor position
	mov		dh, 0			; Set X to 0
	mov		dl, 0			; Set Y to 0
	xor		bh, bh			; Set BH to 0
	int		0x10
	mov		si, boot_str
	call	print
	
	mov		si, krldr_dap
	mov		dl, [drv_num]	; Read next 64 sectors from drive
	mov		ah, 0x42
	int		0x13
	jc		drv_load_error	; Error (if CF is 1)
	
	jmp		[krldr]			; Jump to kernel loader
	
	
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


; Data
disk_err_str	db	'DISK ERROR!', 0x0d, 0x0a, 0x00
boot_str		db	'MYOS BOOT', 0x0d, 0x0a, 0x00

drv_num			db	0x80


; Disk Addres Packet structure
krldr_dap		dw	0x1000
				dw	0x0040	; Number of sectors to be read
krldr			dw	0x7f00	; Segment offset
				dw	0x0000	; Segment
				dq	0x01	; Absolute number of the start of the sectors to be read


db	0xff	; End of bootloader


times 510-($-$$) db 0		; Set remain bytes to zero
db 0x55, 0xAA				; Boot signature