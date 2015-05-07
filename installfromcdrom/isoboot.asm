;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; Boot from selected drive
; Check out the makefile, all drives are equal
;
; Rik van den Eijnden 2015
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

[BITS 16]			; 16 bits real mode
[ORG 0x7c00]			; assume this start address (origin) after loading

IOBUF equ 0x00000c00		; our read buffer

;
; Here we align our segments
;
	xor ax,ax
	;mov cs,ax		;still would really mess things up!!!
	mov ds,ax
	mov ss,ax

;
; The user or BIOS has selected a drive to boot from
; The BIOS has stored it in dl
; Let's make a copy
;
	push dx	
;
; Print title of program
;
	mov si,creds
	call msg
	mov si,newl
	call msg
;
; Print the drive-number we are booting from
;
	mov si,drive
	call msg
	pop dx
	push dx
	mov ah,dl
	call outbx
	mov si,newl
	call msg
;
; Reading from floppy (which can aslo be a cdrom emulating a floppy)
; Is different from reading from a hard-disk
;
	pop dx			; set selected drive
	cmp dl,0x80		; hard-disks start at 0x80
	jb fdread			; drive number below means floppy read
	jmp hdread
;
; Read a sector from the hard-disk with number in dl
;
hdread:
	mov WORD [dap+2], 0x01	; 2 bytes number of sectors to read
	mov DWORD [dap+4], IOBUF; segment:offset pointer to mem buf
	mov WORD [dap+8], 0x1	; absolute sector number, zero based
	mov ah,0x42		; function 42h
	mov si, dap		; pointer to DAP, ds = 0x0
	int 0x13
	jc readerror		; check carry flag, ah has errorcode
	jmp bufdump
;
; Read a sector from a floppy-disk, drive number is in dl
fdread:
	mov ah,0x02		; function 42h
	mov al,0x01		; read 1 sector
	mov ch,0x0		; tracknumber, zero-based
	mov cl,0x2		; sectornumber, one-based!!!!!
	mov dh,0x0		; head number
	mov bx,IOBUF
	int 0x13
	jc readerror		; check carry flag, ah has errorcode
	jmp bufdump
;
; Hexdump the sector (512 bytes) pointed to by IOBUF
;
bufdump:
	mov cx, 512
	mov di,IOBUF
	call memdumphexv2
;
; Now write the buffer we just read to hdb
;
	mov ax,0x0
	mov dl,0x81	;hdb
	call hdwrite

jmp zapp
;
; An error occured when reading a sector from a drive
;
readerror:
	push ax			; keep error code for last
	mov si, rerr
	jmp outerr
;
; An error occured when writing a sector to a drive
;
writeerror:
	push ax			; keep error code for last
	mov si, werr
	jmp outerr
;
; Output the errormessage in si
; Followed by the error code in ah
;
outerr:
	call msg		; print null terminated string in si
	pop ax
	call outbx		; print ah in hex
	jmp zapp
;
; Nothing left to do...
;
zapp:
	mov si,reboot		; announce reboot on keypress
	call msg
	mov ah,0x0		; await user input
	int 0x16
	jmp 0xf000:0xfff0	; reset vector address

; 
; This is my memory area
;
;
; hex translation table
;
hextable:	db	"0123456789ABCDEF"
;
; msg strings must be null terminated
;
creds: 		db	"ISO-boot 0.1 booting... ",0
oks: 		db	"ok ",0
werr: 		db	"Write error ",0
rerr: 		db	"Read error ",0
reboot:		db	"Press key to reboot...",0
drive:		db	"Selected drive:",0
newl:		db	0x0a,0x0d,0
;
; data address packet for reading from hd
;
dap		db	0x10	; size of dap = 16
		db	0x0	; unused
		dw	0x0	; number of sectors to be read
		dw	0x0	; :offset pointer to membuf (little endian for x86)
		dw	0x0	; segment: pointer to membuf (little endian for x86)
		dd	0x0	; absolute number of sector to read (0-based)
		dd	0x0	; used for upper part of 48 bit LBAs

;
; Write 1 sector to disk (512 bytes)
; Sector number (zero based) should be in ax
; Drive number in dl
; Trashes ax,si
; The data is read from memory at IOBUF
hdwrite:
	mov WORD [dap+2],0x01	; 2 bytes number of sectors to write
	mov DWORD [dap+4],IOBUF	; segment:offset pointer to mem buf
	mov WORD [dap+8],ax	; absolute sector number, zero based
	mov ah,0x43		; function 43h
	mov al,0x01		; open write checl
	mov si, dap		; pointer to DAP, ds = 0x0
	int 0x13
	jc writeerror		; check carry flag, ah has errorcode
	ret

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
; Output a NULL terminated string
; located in ds:si
; trashes ax,bx
;
display:
	mov ah, 0x0e		;function #
	mov bh, 0x00		;page
	mov bl, 0x01		;color
	int 0x10		;interrupt teletype output
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
;	This is the sector that will be installed
;	On boot just print out a success message ('Installed!')
;	Can't use labels and addresses since nasm calculates before we 
;	cut out a single section
;++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
s1:
	mov al,'I'
	mov ah, 0x0e	;function teletype write
	mov bh, 0x00	; videopage
	mov bl, 0x01	; colour
	int 0x10	; int video services
	mov al,'n'
	int 0x10
	mov al,'s'
	int 0x10
	mov al,'t'
	int 0x10
	mov al,'a'
	int 0x10
	mov al,'l'
	int 0x10
	mov al,'l'
	int 0x10
	mov al,'e'
	int 0x10
	mov al,'d'
	int 0x10
	mov al,'!'
	int 0x10
	jmp $

times 510-($-s1) db 0	; fill with 0-bytes

db 0x55			; end sector with 'magic  number 55aa
db 0xaa			; which means 'bootable disk

;times 1228800-($-$$) db 0 	; fill with 0 up to 1200kb, emulating a floppy
times 1474560-($-$$) db 0 	; fill with 0 up to 1440kb, emulating a floppy
;++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
