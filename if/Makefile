
build:
	nasm -f elf if.asm
	ld -s -m elf_i386  if.o 

run:	build
	./a.out

clean:
	rm -f if.o a.out
