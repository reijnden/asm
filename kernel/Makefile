
build:
	mkdir -p image
	nasm -f bin boot.asm -o image/boot
	nasm -f bin disk.asm -o image/disk

clean:
	rm -rf image
	rm -f boot.iso

image:	build
	genisoimage -o boot.iso -b boot image

run:	image
	qemu -curses -hda image/disk -cdrom boot.iso -boot d
