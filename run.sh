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
  -net user,hostfwd=tcp:127.0.0.1:2222-:22 \
  -net nic,model=e1000-82545em

cd ..
