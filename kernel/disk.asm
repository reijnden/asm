;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; Hard disk image
; Boot program will jump to 0x0a
;
; Rik van den Eijnden 2015
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
[BITS 16]			; default for bin outputformat...
;++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
;	SECTOR 0
;++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
times 10 db 0	; fill with 0-bytes until first instruction 

sector0:
	mov al, '!'
	mov ah, 0x0e
	mov bh, 0x00
	mov bl, 0x01
	int 0x10		;interrupt teletype output
	jmp $

times 512-($-$$) db 0
;++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
;	SECTOR 1
;++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
times 512 db 0x1	; fill with 1
;++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
;	SECTOR 2
;++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
times 512 db 0x2	; fill with 2
;++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
;	SECTOR N
;++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
times 512 db 0x03	; 
times 512 db 0x04	;
times 512 db 0x05	;
times 512 db 0x06	;
times 512 db 0x07	;
times 512 db 0x08	;
times 512 db 0x09	;
times 512 db 0x0a	;
times 512 db 0x0b	;
times 512 db 0x0c	;
times 512 db 0x0d	;
times 512 db 0x0e	;
times 512 db 0x0f	;
times 512 db 0x10	;
times 512 db 0x11	;
times 512 db 0x12	;
times 512 db 0x13	;
times 512 db 0x14	;
times 512 db 0x15	;
times 512 db 0x16	;
times 512 db 0x17	;
times 512 db 0x18	;
times 512 db 0x19	;
times 512 db 0x1a	;
times 512 db 0x1b	;
times 512 db 0x1c	;
times 512 db 0x1d	;
times 512 db 0x1e	;
times 512 db 0x1f	;
