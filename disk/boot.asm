;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; Hard disk services interrupts
;
; Rik van den Eijnden 2015
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

[BITS 16]			; default for bin outputformat...
[ORG 0x7c00]			; assume this start address (origin) after loading

IOBUF equ 0x00000c00

;
; Check that we are loaded at 0x07c00
; by calling and popping ip into ax
; this must be the first instruction plus 3 bytes for the call instruction
;
call next_line	; this call pushes the current ip to the stack for ret
next_line:
	pop ax	; ax now holds instruction pointer value
	cmp ax, 0x7c03
	jnz error
	call outwx		; first output ax

jmp prms

;read sector #2
;	mov ax, 0x1	;zero based
;	mov cx, 1	;read cx sectors
;sectreadloop:
;	push cx
;	push ax
;	call readsector
;	mov cx, 512
;	mov di,IOBUF
;	call memdumphexv2
;	pop ax
;	pop cx
;	inc ax
;	loop sectreadloop

;write back to sector #1
;	mov ax, 0x0
;	call writesector

;jmp IOBUF ; jump to address where next sector is loaded 

;
; Reset disk controller
;
;reset:				; disk controller reset
;	mov si, resets
;	call msg
;	mov ah, 0x00		; function number
;	mov dl, 0x80		; drive number (80 - ff)
;	int 0x13		; hard disk services interrupt
;	jc error		; check carry flag, ah has errorcode
;	call out
;
; Disk controller status
;
;status:				; disk controller status
;	mov si, statuss
;	call msg
;	mov ah, 0x01		; function number
;	mov dl, 0x80		; drive number (80 - ff)
;	int 0x13		; hard disk services interrupt
;	jc error		; check carry flag, ah has errorcode
;	call out
;
; Disk parameters
;
prms:
	mov si, prmss
	call msg
	mov ah, 0x08		; function number
	mov dl, 0x80		; drive number (80 - ff)
	xor bx, bx		; buggy bios workaround
	mov es, bx		;
	int 0x13		; hard disk services interrupt
	jc error		; leave on error
;
;	; no errors, now both cx and dx contain important values
;	; ch 7-0 bits of 12 bits max cilnumber
;	; cl 9-8 bits of 12 bits max cilnumber in bits 7-6
;	; cl max sectnumber in bits 5-0
;	; dh max headnumber in bits 5-0
;	; dl number of drives 1 or 2 (I don't care)
	push cx
	push dx
	call out
	pop dx				;
	pop cx				;
	mov [maxhead], dh		; 
	and BYTE [maxhead], 0x3F	; bits 5-0 are heads

	mov [maxsect], cl		; 
	and BYTE [maxsect], 0x3F	; bits 5-0 are sectors (and with 0011 1111)

	shr cl, 6			; bits 7-6 to 1-0
	xchg cl,ch			; switch regs 
	mov WORD [maxcil], cx		; save

	mov si, cylinderss
	call msg
	mov ax, [maxcil]
	call outwx
	mov si, sectorss
	call msg
	mov al, [maxsect]
	call outbx
	mov si, headss
	call msg
	mov al, [maxhead]
	call outbx

jmp done

error:
	push ax			; keep error code for last
	mov si, errs
	call msg
	mov al,ah
	call outc
	pop ax
	call outbx		; print errorcode
	jmp done

out:				; output code is in ah
	push ax			; keep error code for later
	mov si, oks
	call msg
	pop ax
	call outbx		; print errorcode (should be 0x00)
	ret

;loopdump:
;	mov ax, 0x00FF
;	mov cx, 255
;.rr:
;	push ax
;	call outwx
;	pop ax
;	inc ax
;	loop .rr
;	ret

done:
	jmp $

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
jmp $	; dont accidentally go beyond this point

;
; Read 1 sector from disk
; Sector number (zero based) should be in ax
; Trashes ax,dl,si
; The data is written to memory at IOBUF
;readsector:	;set disk access packet and go
;	;SET DAP
;	mov WORD [dap+2], 0x01	; 2 bytes number of sectors to read
;	mov DWORD [dap+4], IOBUF	; segment:offset pointer to mem buf
;	mov WORD [dap+8], ax	; absolute sector number, zero based
;	;GO
;	mov ah,0x42		; function 42h
;	mov dl, 0x80		; hd1
;	mov si, dap		; pointer to DAP, ds = 0x0
;	int 0x13
;	jc error		; check carry flag, ah has errorcode
;	ret

;
; Write 1 sector to disk (512 bytes)
; Sector number (zero based) should be in ax
; Trashes ax,dl,si
; The data is read from memory at IOBUF
;writesector:	;set disk access packet and go
;	;SET DAP
;	mov WORD [dap+2], 0x01	; 2 bytes number of sectors to read
;	mov DWORD [dap+4], IOBUF	; segment:offset pointer to mem buf
;	mov WORD [dap+8], ax	; absolute sector number, zero based
;	;GO
;	mov ah,0x43		; function 43h
;	mov al,0x01		; open write checl
;	mov dl, 0x80		; hd1
;	mov si, dap		; pointer to DAP, ds = 0x0
;	int 0x13
;	jc error		; check carry flag, ah has errorcode
;	ret

; 
; This is my memory area
;
startmem:	db	10,13,"++++++++++MEMSTART++++++++++",10,13
;
; hex translation table
;
hextable:	db	"0123456789ABCDEF"
;
; msg strings must be null terminated
;
headss:	 	db	10,13,"Heads(0-based):",0
sectorss: 	db	10,13,"Sectors(0-based):",0
cylinderss: 	db	10,13,"Cylinders(0-based):",0
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
dap		db	0x10	; size of dap = 16
		db	0x0	; unused
		dw	0x0	; number of sectors to be read
		dd	0x0	; segment:offset pointer to membuf (little endian for x86)
		dd	0x0	; absolute number of sector to read (0-based)
		dd	0x0	; used for upper part of 48 bit LBAs
endmem:		db	10,13,"++++++++++MEMEND++++++++++",10,13
memlen equ $-startmem

;
; print out hex values of memory area pointed to by di
; length of block must be in cx
; trashes ax,bx,cx
;
memdumphexv2:
	mov bx, 0
.dump:
	mov ah, [di+bx]
	push bx
	call outbx
	pop bx
	inc bx
	loop .dump
	ret
;
; write current memory area to output (hex)
;
;memdumphex:
;	mov cx, memlen
;	mov bx, 0
;.dump:
;	mov ah, [startmem+bx]
;	push cx
;	push bx
;	call outbx
;	pop bx
;	pop cx
;	inc bx
;	loop .dump
;	ret
;
; print out ascii values of memory area pointed to by di
; length of block must be in cx
; trashes ax,bx,cx
;
memdumpv2:
	mov bx, 0
.dump:
	mov al, [di+bx]
	push bx
	call outc	;outc trashed ah,bx
	pop bx
	inc bx
	loop .dump
	ret
;
; endof memdump
;
;
; output ascii values of memory area pointed to by di
; length of block must be in cx
;
;memdump:
;	mov cx, memlen
;	mov bx, 0
;.dump:
;	mov al, [startmem+bx]
;	push bx
;	call outc	;outc trashed ah,bx
;	pop bx
;	inc bx
;	loop .dump
;	ret
;
; endof memdump
;

display:
	mov ah, 0x0e		;function #
	mov bh, 0x00		;page
	mov bl, 0x01		;color
	int 0x10		;interrupt teletype output
;
; Output a NULL terminated string
;
msg:
	lodsb
	cmp al,0x0
	jnz display
	ret

;
; Output the low nibble of ah as a hexadecimal character
; Use the decimal value as offset into the hextable table
; Trashes ax,bx
;
outnx:
	xor bx,bx
	mov bl,ah
	mov al, [hextable+bx]	; 
	call outc		; al is now set to go
	ret

;
; Output the byte in ah as hexadecimal characters
; (High nibble first)
; Trashes ax,bx
;
outbx:				; output the byte in ah as hex
	push ax			; save a copy, low nibble
	shr ah, 4		; high nibble
	call outnx
	pop ax
	and ah, 0x0F		; low nibble
	call outnx
	ret

;
; Output the word in ax as hexadecimal characters
;
outwx:
	push ax			;save copy for second byte
	call outbx
	pop ax
	shl ax,8
	call outbx
	ret

;
; Teletype output the ascii value in al
; Trashes ah,bx
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

;++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
;	SECTOR 1
;++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
sector1:
	mov al, '!'
	mov ah, 0x0e
	mov bh, 0x00
	mov bl, 0x01
	int 0x10		;interrupt teletype output
	jmp sector1

times 512-($-sector1) db 0
;++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
;	SECTOR 2
;++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
sector2:
times 512 db 0x2	; fill with 2
;++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
;	SECTOR 3
;++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
times 512 db 0x3	; fill with 3
;++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
;	SECTOR N
;++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
times 512 db 0x4	; 
times 512 db 0x5	;
times 512 db 0x6	;
times 512 db 0x7	;
times 512 db 0x8	;
times 512 db 0x9	;
times 512 db 0xa	;
times 512 db 0xb	;
times 512 db 0xc	;
times 512 db 0xd	;
times 512 db 0xe	;
times 512 db 0xf	;
