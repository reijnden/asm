
build:
	nasm -f elf -g -F stabs scratch.asm
	ld -m elf_i386  scratch.o 

run:	build
	./a.out

clean:
	rm -f scratch.o a.out
