#! /bin/sh

LFS_VERSION=7.8; export LFS_VERSION
#LFS_VERSION=stable; export LFS_VERSION

chroot /path/to/lfs-7.8

# su
cd /bin
rm sh
ln -s bash sh

mount -t proc none /proc
mount -t devtmpfs none /dev
mount -t devpts none /dev/pts

apt-get install vim less wget gawk bison make bzip2 gcc xz-utils g++ patch perl-modules texinfo
