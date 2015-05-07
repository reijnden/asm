#
# Makefile for ISOBoot
# ISOBoot will boot from hd, fd, or cdrom
# and install sector 1 to hdb
#
build:
	@mkdir -p image
	@nasm -f bin isoboot.asm -o image/isoboot

clean:
	rm -rf image
	rm -f boot.iso hd.img

image:	build
	@genisoimage -o boot.iso -b isoboot image
	@qemu-img create hd.img 1M

bootrun:image
	@qemu-system-i386 -curses -hdb hd.img -hda image/isoboot -fda image/isoboot -cdrom boot.iso -boot menu=on

hdrun:
	@qemu-system-i386 -curses -hda hd.img -boot c

