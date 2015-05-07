;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; Hard disk services interrupts
;
; Rik van den Eijnden 2015
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

[BITS 16]			; default for bin outputformat...
[ORG 0x7c00]			; assume this start address (origin)  after loading

;
; set segments to 0
;
preset:				; set segment pointers
	xor ax,ax
	mov ds,ax
	mov ss,ax

	call memdump

; 
; This is my memory area
;
startmem:	db	"++++++++++++++++++++"
;
; hex translation table
;
hextable:	db	"0123456789ABCDEF"
;
; msg strings must be null terminated
;
resets:	 	db	10,13,"Reset:",0
statuss: 	db	10,13,"Status:",0
prmss:	 	db	10,13,"Params:",0
oks: 		db	"ok ",0
errs: 		db	"err ",0
;
; data
;
maxhead:	db	'-'
maxsect:	db	'-'
maxcil:		db	'-'
		db	'-'
endmem:		db	"++++++++++++++++++++"
memlen equ $-startmem

memdump:
	mov cx, memlen
	mov bx, 0
dump:
	mov al, [startmem+bx]
	push cx
	push bx
	call outc
	pop bx
	pop cx
	inc bx
	loop dump
	ret

;
; Teletype output the ascii value in al
;
outc:				;output the ascii character in al
	mov ah, 0x0e
	mov bh, 0x00
	mov bl, 0x01
	int 0x10		;interrupt teletype output
	ret

times 510-($-$$) db 0	; fill with 0-bytes

db 0x55			; end sector with 'magic  number 55aa
db 0xaa			; which means 'bootable disk

