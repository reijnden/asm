
build:
	nasm -f bin boot.asm 

objdump:
	objdump -D -b binary -mi386 -Maddr16,data16,intel boot

hex:
	hexdump -Cv boot

run:
	qemu-system-i386 -curses boot

clean:
	rm -f boot

exp:
	qemu -localtime -net user -net nic -m 256 -hda boot -curses
