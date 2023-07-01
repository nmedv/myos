#include <stdbool.h>
#include <stddef.h>
#include <stdint.h>


/* Hardware text mode color constants. */
enum vga_color {
	VGA_COLOR_BLACK = 0,
	VGA_COLOR_BLUE = 1,
	VGA_COLOR_GREEN = 2,
	VGA_COLOR_CYAN = 3,
	VGA_COLOR_RED = 4,
	VGA_COLOR_MAGENTA = 5,
	VGA_COLOR_BROWN = 6,
	VGA_COLOR_LIGHT_GREY = 7,
	VGA_COLOR_DARK_GREY = 8,
	VGA_COLOR_LIGHT_BLUE = 9,
	VGA_COLOR_LIGHT_GREEN = 10,
	VGA_COLOR_LIGHT_CYAN = 11,
	VGA_COLOR_LIGHT_RED = 12,
	VGA_COLOR_LIGHT_MAGENTA = 13,
	VGA_COLOR_LIGHT_BROWN = 14,
	VGA_COLOR_WHITE = 15,
};

static const size_t VGA_WIDTH = 80;
static const size_t VGA_HEIGHT = 25;
/* static size_t VGA_TAB_WIDTH = 4; */
static uint16_t* VGA_BUFFER = (uint16_t*) 0xB8000;

static size_t terminal_row;
static size_t terminal_column;
static uint8_t terminal_color;


size_t strlen(const char* str)
{
	size_t len = 0;
	while (str[len])
		len++;
	return len;
}

static inline uint8_t vga_entry_color(enum vga_color fg, enum vga_color bg)
{
	return fg | bg << 4;
}

static inline uint16_t vga_entry(unsigned char uc, uint8_t color)
{
	return (uint16_t) uc | ( (uint16_t) color << 8 );
}

void terminal_initialize(void)
{
	terminal_row = 0;
	terminal_column = 0;
	terminal_color = vga_entry_color(VGA_COLOR_LIGHT_GREY, VGA_COLOR_BLACK);
	for (size_t i = 0; i < VGA_HEIGHT * VGA_WIDTH; i++) {
		VGA_BUFFER[i] = vga_entry(' ', terminal_color);
	}
}

void terminal_setcolor(uint8_t color)
{
	terminal_color = color;
}

void terminal_putentryat(char c, uint8_t color, size_t x, size_t y)
{
	const size_t index = y * VGA_WIDTH + x;
	VGA_BUFFER[index] = vga_entry(c, color);
}

void terminal_shiftup(size_t lines)
{
	if (lines < VGA_HEIGHT)
	{
		size_t shift = lines * 40;
		uint32_t* buffer = (uint32_t*)VGA_BUFFER;

		for (size_t i = shift; i < 1000; i++)
			buffer[i - shift] = buffer[i];

		for (size_t i = 1000 - shift; i < 1000; i++)
			buffer[i] = vga_entry(' ', terminal_color);
	}
	else terminal_initialize();
}

void terminal_newline(void)
{
	terminal_column = 0;
	if (terminal_row < 24)
		++terminal_row;
	else
		terminal_shiftup(1);
}

void terminal_putchar(char c)
{
	if (c == '\n') {
		terminal_newline();
		return;
	}
	else
		terminal_putentryat(c, terminal_color, terminal_column++, terminal_row);
	
	if (terminal_column == VGA_WIDTH)
		terminal_newline();
}

void terminal_write(const char* data, size_t size)
{
	for (size_t i = 0; i < size; i++)
		terminal_putchar(data[i]);
}

void terminal_writestring(const char* data)
{
	terminal_write(data, strlen(data));
}