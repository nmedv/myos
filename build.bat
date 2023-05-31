@echo off

REM	Building boot sector
nasm -f bin %~dp0src\boot.asm -o %~dp0bin\boot.bin
nasm -f bin %~dp0src\krldr.asm -o %~dp0bin\krldr.bin
gcc -ffreestanding -c -o %~dp0bin\kernel.o %~dp0src\kernel.c
ld 

REM	Making ISO file
rem del %~dp0bin\myos.iso /f /q
dd if=/dev/zero of=%~dp0bin\myos.iso bs=512 count=256
dd if=%~dp0bin\boot.bin of=%~dp0bin\myos.iso conv=notrunc bs=512 seek=0 count=1
dd if=%~dp0bin\krldr.bin of=%~dp0bin\myos.iso conv=notrunc bs=512 seek=1 count=64

exit /b 0