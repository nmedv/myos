#=============================================================================
# Set variables for assembler, C compiler and linker.

ASM = nasm

CC = i686-elf-gcc
CCFLAGS = -Wall -Wextra -Werror -ffreestanding
CCFLAGS += -nostdlib -nostdinc -fno-builtin -m32 -c

OC = i686-elf-objcopy

LD = i686-elf-ld


#=============================================================================
# Set default functions

.PHONY: all dirs clean

all: dirs boot krldr kernel iso

dirs:
	mkdir -p build
	mkdir -p build/kernel

clean:
	rm -r -f build/*


#=============================================================================
# Build bootsector and kernel loader

boot:
	$(ASM) -f bin -o build/boot src/boot.asm

krldr:
	$(ASM) -f bin -o build/krldr -I src/krldr src/krldr/krldr.asm


#=============================================================================
# Build kernel (todo)

# recursive:
# KERNEL_SRCS_C = $(shell find src/kernel -name "*.c")
# KERNEL_SRCS_ASM = $(shell find src/kernel -name "*.asm")
# @echo "KERNEL_SRCS_C = $(KERNEL_SRCS_C)"
# @echo "KERNEL_SRCS_ASM = $(KERNEL_SRCS_ASM)"
# @echo "KERNEL_OBJS = $(KERNEL_OBJS)"

KERNEL_SRCS_C = $(wildcard src/kernel/*.c)
KERNEL_SRCS_ASM = $(wildcard src/kernel/*.asm)
KERNEL_HDRS = src/kernel/include
KERNEL_OBJS = \
	$(patsubst src/kernel/%.c, build/kernel/%.o, $(KERNEL_SRCS_C)) \
	$(patsubst src/kernel/%.asm, build/kernel/%.o, $(KERNEL_SRCS_ASM))

build/kernel/%.o: src/kernel/%.c
	$(CC) -g $(CCFLAGS) -I $(KERNEL_HDRS) -o $@ $<

build/kernel/%.o: src/kernel/%.asm
	$(ASM) -f elf32 -o $@ $<

kernel: $(KERNEL_OBJS)
# -T src/link.ld 
	$(LD) -o build/kernel.elf $^
# Save debug symbols to build/kernel.sym:
	$(OC) --only-keep-debug build/kernel.elf build/kernel.sym
# Remove debug symbols from build/kernel.bin:
	$(OC) --strip-debug build/kernel.elf


#=============================================================================
# Make ISO file

ISO = build/myos.iso

iso: boot krldr kernel
	dd if=/dev/zero of=$(ISO) bs=512 count=256
	dd if=build/boot of=$(ISO) conv=notrunc bs=512 seek=0 count=1
	dd if=build/krldr of=$(ISO) conv=notrunc bs=512 seek=1 count=64
	dd if=build/kernel.elf of=$(ISO) conv=notrunc bs=512 seek=65