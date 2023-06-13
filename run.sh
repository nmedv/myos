#!/bin/bash

qemu-system-i386 -drive \
	format=raw,index=0,if=ide,file="build/myos.iso"