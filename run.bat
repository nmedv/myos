@echo off

start ^
	qemu-system-i386 ^
	-drive format=raw,index=0,if=ide,file=%~dp0bin\myos.iso

exit /b 0