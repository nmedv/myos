#include "idt.h"

/* Declared in idt.asm */
extern void* isr_stub_table[];
void idt_load(uintptr_t idtr);

__attribute__((aligned(0x10))) static idt_entry_t idt[256];
static idtr_t idtr;

void idt_set_descriptor(uint8_t vector, void* isr, uint8_t flags)
{
	idt_entry_t* descriptor = &idt[vector];

	descriptor->isr_low		= (uint32_t)isr & 0xFFFF;
	descriptor->kernel_cs	= KERNEL_CS;
	descriptor->attributes	= flags;
	descriptor->isr_high	= (uint32_t)isr >> 16;
	descriptor->reserved	= 0;
}

void idt_init(void) {
	idtr.base = (uintptr_t)&idt[0];
	idtr.limit = (uint16_t)sizeof(idt_entry_t) * IDT_MAX_DESCRIPTORS - 1;

	for (uint8_t vector = 0; vector < IDT_MAX_DESCRIPTORS; vector++) {
		idt_set_descriptor(vector, isr_stub_table[vector], 0x8E);
		/* vectors[vector] = true; */
	}

	idt_load((uintptr_t)&idtr);
}