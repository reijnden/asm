
build:
	nasm -f elf read.asm
	ld -s -m elf_i386  read.o 

run:	build
	./a.out

clean:
	rm -f read.o a.out
