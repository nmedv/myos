#include "io.h"

inline uint8_t inb(uint16_t port)
{
	uint8_t ret;
	asm volatile ("inb %1, %0" : "=a"(ret) : "Nd"(port) : "memory");
	return ret;
}

inline void outb(uint16_t port, uint8_t val)
{
	asm volatile ("outb %0, %1" : : "a"(val), "Nd"(port) : "memory");

	/* 
	 * There's an outb %al, $imm8  encoding, for compile-time constant port
	 * numbers that fit in 8b.  (N constraint). Wider immediate constants would
	 * be truncated at assemble-time (e.g. "i" constraint). The  outb  %al, %dx
	 * encoding is the only option for all other cases. %1 expands to %dx
	 * because  port  is a uint16_t.  %w1 could be used if we had the port
	 * number a wider C type
	 */
}

inline void io_wait(void)
{
    outb(0x80, 0);
}