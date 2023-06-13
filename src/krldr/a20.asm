bits 16

global enable_a20

section .text

; Enable A20 line
enable_a20:
	call	check_a20
	cmp		al, 0x01
	je		enable_a20_end
	; todo: add code to enable a20 line!!!
	
enable_a20_end:
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


section .data

buffer_belowMB	db	0
buffer_overMB	db	0