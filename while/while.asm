%include "../macro/syscall.mac"
; data section
section .data
	ask db "Type a number between 0 and 9..."
	alen equ $ - ask
	tsm db "too small"
	tlen equ $ - tsm
	tbig db "too big"
	flen equ $ - tbig
	good db "Correct!"
	glen equ $ - good
	hint db "Hint:"
	hlen equ $ - hint
	newline db 0x0a 	;length = 1
	
; variable section
section .bss
	boot resd 1
	char resd 1
	dummy resd 1
; code section
section .text
global _start

readinput:
	write 1, ask, alen
	write 1, newline, 1
	read 0, char, 1
	read 0, dummy, 1
	jmp check

check:
	xor eax, eax
	or eax, [boot] 		;these 2 lines are equivalent to 
				;mov eax, [boot]
	cmp eax, [char]		;compare with VALUE of char
	jb big
	ja small
	jmp correct

givehint:
	write 1, hint, hlen
	write 1, boot, 1
	write 1, newline, 1
	jmp readinput

small:
	write 1, tsm, tlen
	write 1, newline, 1
	jmp givehint

big:
	write 1, tbig, flen
	write 1, newline, 1
	jmp givehint

correct:
	write 1, good, glen
	write 1, newline, 1
	jmp end

end:
	exit 0

_start:
	read 0, boot, 1
	read 0, dummy, 1
	jmp readinput
