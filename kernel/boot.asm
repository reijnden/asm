;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; 512 Bytes generic boot program.
; Will jump to instruction on 0x0a
; on first sector of hda
;
; Rik van den Eijnden 2015
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
[BITS 16]			; default for bin outputformat...
[ORG 0x7c00]			; assume this start address (origin) after loading
IOBUF equ 0x00000c00		; address where sector is loaded

; Here we read first sector of hda
;SET DAP
	mov WORD [dap+2], 0x01	; 2 bytes number of sectors to read
	mov DWORD [dap+4], IOBUF	; segment:offset pointer to mem buf
	mov WORD [dap+8], 0x0	; absolute sector number, zero based
;GO
	mov ah,0x42		; function 42h
	mov si, dap		; pointer to DAP, ds = 0x0
	mov dl, 0x80		; hda, hdb = 0x81 etc
	int 0x13
	jc error		; check carry flag, ah has errorcode
	jmp IOBUF+10
done:
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
jmp $	; dont accidentally go beyond this point
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
;
; Read 1 sector from disk, nr is in dl
; Sector number (zero based) should be in ax
; Trashes ax,si
; The data is written to memory at IOBUF
readsector:	;set disk access packet and go
	;SET DAP
	mov WORD [dap+2], 0x01	; 2 bytes number of sectors to read
	mov DWORD [dap+4], IOBUF	; segment:offset pointer to mem buf
	mov WORD [dap+8], ax	; absolute sector number, zero based
	;GO
	mov ah,0x42		; function 42h
	mov si, dap		; pointer to DAP, ds = 0x0
	int 0x13
	jc error		; check carry flag, ah has errorcode
	ret
; 
; This is my memory area
;
startmem:	
;
; hex translation table
;
hextable:	db	"0123456789ABCDEF"
;
; msg strings must be null terminated
;
oks: 		db	"ok ",0
errs: 		db	"err ",0
;
; data
;
dap		db	0x10	; size of dap = 16
		db	0x0	; unused
		dw	0x0	; number of sectors to be read
		dd	0x0	; segment:offset pointer to membuf (little endian for x86)
		dd	0x0	; absolute number of sector to read (0-based)
		dd	0x0	; used for upper part of 48 bit LBAs
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
; end of bootable sector

; an eltorito boot image must be 1200,1440 or 2880 KB exactly, so let fill her up to 1200...
times 512 db 0		; fill a sector with 0-bytes, completing the first kb
times 1024*1199 db 0	; 1199 more kb's, making 1200

