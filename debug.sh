#!/bin/bash

if [ "$1" = "" ]; then
	echo "Usage: debug (krldr | kernel)"
elif [ "$1" = "krldr" ]; then
	i686-elf-gdb -q -ix "scripts/gdb_krldr.gdb"
elif [ "$1" = "kernel" ]; then
	i686-elf-gdb -q -ix "scripts/gdb_kernel.gdb"
else
	echo "Usage: debug (krldr | kernel)"
fi
