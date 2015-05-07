;============================================================================
; 
; Copyright 2014, 2015 Rik vd Eijnden
; 
;============================================================================

;============================================================================
; Macros for system calls
;============================================================================
%include "../macro/syscall.mac"

; calculate position in scratch space
; only modifies eax
%macro getpos 3
	mov eax, %1			; set eax to scratch
	add eax, %2			; add scratch length
	sub eax, %3			; subtract decremented ecx
; eax is now holding correct address
%endmacro

%macro PRINTCHAR 1
	push edx
	mov edx, %1
	call printchar
	pop edx
%endmacro

;============================================================================
; Data
;============================================================================
section .data
	scratchsize equ 5		; size of our scratch pad
	
;============================================================================
; Bss
;============================================================================
section .bss
	scratch resb scratchsize	; scratch memory, scratchsize bytes
	char2print resb 4;

;============================================================================
; Text
;============================================================================
section .text

global _start

;============================================================================
; prints edx to stdout
;============================================================================
printchar:
	pusha
	mov [char2print], edx
	mov ecx, char2print
	write 1, ecx, 4
	popa
	ret

;============================================================================
; dump a 32 bit register to stdout (binary)
;============================================================================
oregbin:
	pusha
	mov ecx, 32			; 32 reps
.bitloop:				; loop start
	shl eax, 1			; 
	jc .one				; carry set? jump to .one for printing '1'
	PRINTCHAR 0x30			; still here? then print '0'
	jmp .nextbit			; jump over  .one
.one:					; print ascii 1
	PRINTCHAR 0x31			; still here? then print '0'
.nextbit:
	loop .bitloop			; again
	PRINTCHAR 0x0a
	popa
	ret

;============================================================================
; main entry point
;============================================================================
_start:
	mov cx, scratchsize		; loop scratchsize times
.readloop:
	getpos scratch, scratchsize, ecx; getpos sets eax to correct address
	push ecx			; save on stack
	push eax			; save on stack
	read 0, eax, 1			; read a byte from stdin into eax
	pop eax				; restore eax
	pop ecx				; restore ecx
	loop .readloop			; read one more unless cx=0

	mov cx, scratchsize		; prepare for writing scratchsize bytes
.writeloop:
	getpos scratch, scratchsize, ecx; getpos sets eax to correct address
	push ecx			; save on stack, since write uses ecx
	call oregbin
	write 1, eax, 1			; write a byte to atdout
	PRINTCHAR 0x0a
	pop ecx				; pop register
	loop .writeloop			; write one more unless cx=0

	exit 0
;============================================================================
; you normally would not end up here
; just for debugging purposes
;============================================================================
.debug:
	xor eax, eax
	inc eax
	mov cx, 10
.debugloop:
	call oregbin
	shl eax, 1
	loop .debugloop

	exit 0
;============================================================================
; EOF
;============================================================================
