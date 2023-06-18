# i386-32bit config
# set tdesc filename scripts/target.xml

# Intel syntax
set disassembly-flavor intel

# Start myos.iso in QEMU i386 emulator
shell qemu-system-i386 \
	-drive format=raw,index=0,if=ide,file="build/myos.iso" -s -S &

# Wait until QEMU is fully started
shell sleep 5

# Load debug symbols
add-symbol-file "build/kernel.sym"