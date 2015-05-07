
build:
	nasm -f elf while.asm
	ld -s -m elf_i386  while.o 

run:	build
	./a.out

clean:
	rm -f while.o a.out
