%include "../macro/syscall.mac"
; data sectie
section .data
	hello db "Hello world", 0x0a
	len equ $ - hello
; code sectie
section .text
global _start
_start:
	write 1, hello, len
	exit 0
