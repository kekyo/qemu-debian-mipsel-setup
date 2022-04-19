#!/bin/bash

# https://gist.github.com/extremecoders-re/3ddddce9416fc8b293198cd13891b68c

#--------------------------------------------
# Require these packages.
echo "sudo apt install qemu qemu-system-mips qemu-utils"
sudo apt install qemu qemu-system-mips qemu-utils

#--------------------------------------------
# Enable qcow mounter.
sudo modprobe nbd max_part=8

#--------------------------------------------
# Create staging directories.
if [ ! -d artifacts ]; then
  mkdir artifacts
fi
if [ ! -d stage ]; then
  mkdir stage
fi
if [ ! -d mnt ]; then
  mkdir mnt
fi

#--------------------------------------------
# Download debian image.
cd artifacts

# Choose mirror server and latest image file.
if [ ! -f debian-*.iso ]; then
  wget http://cdimage.debian.org/cdimage/release/current/mipsel/iso-cd/debian-11.3.0-mipsel-netinst.iso
fi

cd ..

#--------------------------------------------
# Extract installer kernel image and root filesystem image.

sudo mount -r -t iso9660 artifacts/debian-*.iso mnt/
cp mnt/install/malta/netboot/vmlinuz* artifacts/vmlinuz-netinst
cp mnt/install/malta/netboot/initrd* artifacts/initrd-netinst.gz
sudo umount mnt/

#--------------------------------------------
# Create hard disk image.

cd stage
qemu-img create -f qcow2 hda.qcow 16G

#--------------------------------------------
# Install debian.

qemu-system-mipsel \
  -M malta \
  -m 1024 \
  -cdrom ../artifacts/debian-*.iso \
  -hda hda.qcow \
  -kernel ../artifacts/vmlinuz-netinst \
  -initrd ../artifacts/initrd-netinst.gz \
  -boot d \
  -nographic \
  -append "root=/dev/sda1 nokaslr"

cd ..

#--------------------------------------------
# Extract bootable kernel image and root filesystem image.

sudo qemu-nbd --connect=/dev/nbd0 `pwd`/stage/hda.qcow
sudo mount -r /dev/nbd0p1 `pwd`/mnt
cp mnt/boot/vmlinuz* stage/vmlinuz
cp mnt/boot/initrd* stage/initrd.img
sudo umount /dev/nbd0p1
sudo qemu-nbd --disconnect /dev/nbd0

#--------------------------------------------

echo "Done."
