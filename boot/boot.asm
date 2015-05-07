[BITS 16]		; default for bin outputformat...
[ORG 0x7c00]		; assume this start address (origin)  after loading

;jmp boot		; assembler instruction
db 0xeb			; OPCODE 0xeb (jmp short) uses the next byte for size
;db 0xe9		; OPCODE 0xe9 (jmp) uses the next 2 bytes for size
db 0x00 		; size
;db 0x00		; another one for 0xe9

boot:			; label used by assembler to calulate jump sizes
;mov al, '!'		; NASM instruction
db 0xb0 		; OPCODE (mov al)
db 0x21			; OPERAND for above
;mov ah, 0x0e		; function 0x0e: write in teletype mode
db 0xb4			; OPCODE (mov ah)
db 0x0e			; OPERAND
;mov bh, 0x00		; number of video page
db 0xb7			; OPCODE (mov bh)
db 0x00			; OPERAND
;mov bl, 0x07		; foreground color
db 0xb3			; OPCODE (mov bl)
db 0x07			; OPERAND

;int 0x10		; BIOS Interrupt: video services
db 0xcd			; OPCODE (int)
db 0x10			; OPERAND

;jmp $
db 0xeb			; OPCODE (jmp short)
db 0xfe			; OPERAND size of jump -1, jmp to jmp

times 510-($-$$) db 0	; fill with 0-bytes

db 0x55			; end sector with 'magic  number 55aa
db 0xaa			; which means 'bootable disk
