%include "../macro/syscall.mac"
; data section
section .data
	ask db "Give me a char..."
	alen equ $ - ask
	tell db "You said: "
	tlen equ $ - tell
	newline db 0x0a ; length = 1
	
; variable section
section .bss
	char resd 1
; code section
section .text
global _start

echo:
	read 0, char, 1
	write 1, char, 1
	
_start:
	write 1, ask, alen
	write 1, newline, 1
	read 0, char, 1
	write 1, tell, tlen
	write 1, char, 1
	write 1, newline, 1
	exit 0
