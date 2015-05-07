%include "../macro/syscall.mac"
; data section
section .data
	ask db "Type a number 0-9..."
	alen equ $ - ask
	true db "<5"
	tlen equ $ - true
	false db ">=5"
	flen equ $ - false
	newline db 0x0a ; length = 1
	
; variable section
section .bss
	char resd 1
; code section
section .text
global _start

small:
	write 1, char, 1
	write 1, true, tlen
	write 1, newline, 1
	jmp end

big:
	write 1, char, 1
	write 1, false, flen
	write 1, newline, 1
	jmp end

end:
	exit 0

_start:
	write 1, ask, alen
	write 1, newline, 1
	read 0, char, 1
	mov eax, 0x35	;0x35 is ascii 5
	cmp eax, [char]	; compare with VALUE of char
	jbe big
	jmp small
