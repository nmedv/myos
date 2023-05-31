@echo off

start qemu-system-i386 ^
	-drive format=raw,index=0,if=ide,file=%~dp0bin\myos.iso ^
	-s -S

timeout /t 4 /nobreak

gdb -ix "%~dp0conf\gdb_init_real_mode.txt" ^
	-ex "set tdesc filename %~dp0conf\target.xml" ^
	-ex "target remote localhost:1234" ^
	-ex "br *0x7c00" -ex "c" ^
	-ex "br *0x7f19"

exit /b 0