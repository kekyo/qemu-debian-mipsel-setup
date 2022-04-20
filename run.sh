#!/bin/bash

#--------------------------------------------
# Run debian on qemu.

cd stage

qemu-system-mipsel \
  -M malta \
  -m 2048 \
  -hda hda.qcow \
  -kernel vmlinuz \
  -initrd initrd.img \
  -append "root=/dev/sda1 console=ttyS0 nokaslr" \
  -nographic \
  -netdev user,id=net0,hostfwd=tcp:127.0.0.1:2222-:22 \
  -device e1000,netdev=net0,id=net0,mac=52:54:00:12:34:56

cd ..
