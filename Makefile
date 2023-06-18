#=============================================================================
# Set variables for assembler, C compiler and linker.

ASM = nasm

CC = i686-elf-gcc
CCFLAGS = -Wall -Wextra -Werror -ffreestanding
CCFLAGS += -nostdlib -nostdinc -fno-builtin -m32 -c
CCFLAGS += -I "${HOME}/opt/cross/lib/gcc/i686-elf/13.1.0/include"

OC = i686-elf-objcopy

LD = i686-elf-ld

# All source files
SRCS = $(shell find src -name *.asm -o -name *.c)


#=============================================================================
# Set default functions

.PHONY: all dirs clean

all: dirs boot krldr kernel iso

dirs:
	mkdir -p build
	mkdir -p build/krldr
	mkdir -p build/kernel

clean:
	rm -r -f build/*


#=============================================================================
# Build bootsector

boot:
	$(ASM) -f bin -o build/boot.bin src/boot.asm
	
	
#=============================================================================
# Build kernel loader

KRLDR_SRCS_C = $(filter src/krldr/%.c, $(SRCS))
KRLDR_SRCS_ASM = $(filter src/krldr/%.asm, $(SRCS))
KRLDR_OBJS = \
	$(KRLDR_SRCS_C:src/krldr/%.c=build/krldr/%.o) \
	$(KRLDR_SRCS_ASM:src/krldr/%.asm=build/krldr/%.o)
KRLDR_HDRS = src/krldr/include
	
build/krldr/%.o: src/krldr/%.c
	$(CC) -g $(CCFLAGS) -I $(KRLDR_HDRS) -o $@ $<

build/krldr/%.o: src/krldr/%.asm
	$(ASM) -g -f elf32 -I$(KRLDR_HDRS) -o $@ $<

krldr: $(KRLDR_OBJS)
	$(LD) -T src/krldr/link.ld -o build/krldr/krldr.elf $^
	$(OC) --only-keep-debug build/krldr/krldr.elf build/krldr.sym
	$(OC) -O binary build/krldr/krldr.elf build/krldr.bin


#=============================================================================
# Build kernel (todo)

KERNEL_SRCS_C = $(filter src/kernel/%.c, $(SRCS))
KERNEL_SRCS_ASM = $(filter src/kernel/%.asm, $(SRCS))
KERNEL_OBJS = \
	$(KERNEL_SRCS_C:src/kernel/%.c=build/kernel/%.o) \
	$(KERNEL_SRCS_ASM:src/kernel/%.asm=build/kernel/%.o)
KERNEL_HDRS = src/kernel/include

build/kernel/%.o: src/kernel/%.c
	$(CC) -g $(CCFLAGS) -I $(KERNEL_HDRS) -o $@ $<

build/kernel/%.o: src/kernel/%.asm
	$(ASM) -g -f elf32 -o $@ $<

kernel: $(KERNEL_OBJS)
	$(LD) -T src/kernel/link.ld -o build/kernel.elf $^
	$(OC) --only-keep-debug build/kernel.elf build/kernel.sym
	$(OC) --strip-debug build/kernel.elf


#=============================================================================
# Make ISO file

ISO = build/myos.iso

iso: boot krldr kernel
	dd if=/dev/zero of=$(ISO) bs=512 count=256
	dd if=build/boot.bin of=$(ISO) conv=notrunc bs=512 seek=0 count=1
	dd if=build/krldr.bin of=$(ISO) conv=notrunc bs=512 seek=1 count=64
	dd if=build/kernel.elf of=$(ISO) conv=notrunc bs=512 seek=65