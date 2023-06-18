# i386-32bit config
set tdesc filename scripts/target.xml

# GDB real mode config
source scripts/gdb_init_real_mode.gdb

# Start myos.iso in QEMU i386 emulator
shell qemu-system-i386 \
	-drive format=raw,index=0,if=ide,file="build/myos.iso" -s -S &

# Wait until QEMU is fully started
shell sleep 5

# Connect to QEMU
target remote localhost:1234

# Load debug symbols
add-symbol-file "build/krldr.sym"

# Bootloader break
br *0x7c00

# Krldr break
br krldr