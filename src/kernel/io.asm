
; inline uint8_t inb(uint16_t port);
inb:
	mov		dx, word [esp + 4]	; dx = port
	xor		eax, eax
	in		al, dx				; al = in(dx)
	ret

; inline uint16_t inw(uint16_t port);
inw:
	mov		dx, word [esp + 4]	; dx = port
	xor		eax, eax
	in		ax, dx				; ax = in(dx)
	ret

; inline uint32_t inl(uint16_t port);
inl:
	mov		dx, word [esp + 4]	; dx = port
	xor		eax, eax
	in		eax, dx				; eax = in(dx)
	ret

; inline uint32_t inl(uint16_t port);
outb:
	