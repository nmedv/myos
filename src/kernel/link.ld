ENTRY(start)

SECTIONS
{
	. = 0x10000 + SIZEOF_HEADERS;
	
	.text :
	{
		build/kernel/assembly/kernel.o(.text)
		*(.text)
	}

	.stack :
	{
		*(.stack)
	}
	
	/* .rdata BLOCK(0x1000) : ALIGN(0x1000)
	{
		*(.rdata)
	}
	
	.data BLOCK(0x1000) : ALIGN(0x1000)
	{
		*(.data)
	}
	
	.bss BLOCK(0x1000) : ALIGN(0x1000)
	{
		*(.bss)
	}
	
	end = .; */
}