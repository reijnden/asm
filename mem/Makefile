
build:
	nasm -f bin boot.asm 

objdump:
	objdump -D -b binary -mi386 -Maddr16,data16,intel boot

hex:
	hexdump -Cv boot

run:
	qemu-system-i386 boot

clean:
	rm -f boot
