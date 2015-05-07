
build:
	nasm -f elf hello.asm
	ld -s -m elf_i386  hello.o -o helloasm

run:	build
	./helloasm
	strace ./helloasm
	time ./helloasm
	gcc hello.c -ohelloc
	./helloc
	strace ./helloc
	time ./helloc

clean:
	rm -f hello.o helloasm helloc
