#include <stdbool.h>
#include "vga.h"

void kmain(void)
{
	terminal_initialize();

	int i = 0;

	while (i++ < 100)
		terminal_writestring("Some string to test if terminal shift is working");

	terminal_writestring("\nWrite some end\n");

	while (true) ;
}