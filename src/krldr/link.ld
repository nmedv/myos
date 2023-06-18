OUTPUT_FORMAT(elf32-i386)

SECTIONS
{
	. = 0x7f00;
	
	.text :
	{
		build/krldr/krldr.o(.text)
		*(.text)
	}
	
	.data :
	{
		*(.data)
	}
}