# Section 6.2. Preparing Virtual Kernel File Systems http://www.linuxfromscratch.org/lfs/view/stable/chapter06/kernfs.html

mkdir -p ${destdir}/{dev,proc,sys,run}

mknod -m 600 ${destdir}/dev/console c 5 1
mknod -m 666 ${destdir}/dev/null c 1 3
mount --bind /dev ${destdir}/dev

mount -t devpts devpts ${destdir}/dev/pts -o gid=5,mode=620
mount -t proc proc ${destdir}/proc
mount -t sysfs sysfs ${destdir}/sys
mount -t tmpfs tmpfs ${destdir}/run

if test -h ${destdir}/dev/shm; then
    mkdir -p ${destdir}/$(readlink ${destdir}/dev/shm)
fi

# Section 6.4. Entering the Chroot Environment http://www.linuxfromscratch.org/lfs/view/stable/chapter06/chroot.html

chroot "${destdir}" /tools/bin/env -i \
    HOME=/root \
    TERM="$TERM" \
    PS1='\A \u@\h \w $? \$ ' \
    PATH=/bin:/usr/bin:/sbin:/usr/sbin:/tools/bin \
    /tools/bin/bash --login +h

# Section 6.5. Creating Directories http://www.linuxfromscratch.org/lfs/view/stable/chapter06/creatingdirs.html

mkdir -p ${destdir}/{bin,boot,etc/{opt,sysconfig},home,lib/firmware,mnt,opt}
mkdir -p ${destdir}/{media/{floppy,cdrom},sbin,srv,var}
install -d -m 0750 ${destdir}/root
install -d -m 1777 ${destdir}/tmp ${destdir}/var/tmp
mkdir -p ${destdir}/usr/{,local/}{bin,include,lib,sbin,src}
mkdir -p ${destdir}/usr/{,local/}share/{color,dict,doc,info,locale,man}
mkdir ${destdir}/usr/{,local/}share/{misc,terminfo,zoneinfo}
mkdir ${destdir}/usr/libexec
mkdir -p ${destdir}/usr/{,local/}share/man/man{1..8}

case $(uname -m) in
x86_64)
    ln -s lib ${destdir}/lib64
    ln -s lib ${destdir}/usr/lib64
    ln -s lib ${destdir}/usr/local/lib64 ;;
esac

mkdir ${destdir}/var/{log,mail,spool}
ln -s /run ${destdir}/var/run
ln -s /run/lock ${destdir}/var/lock
mkdir -p ${destdir}/var/{opt,cache,lib/{color,misc,locate},local}

# Section 6.6. Creating Essential Files and Symlinks http://www.linuxfromscratch.org/lfs/view/stable/chapter06/createfiles.html

ln -s /tools/bin/{bash,cat,echo,pwd,stty} ${destdir}/bin
ln -s /tools/bin/perl ${destdir}/usr/bin
ln -s /tools/lib/libgcc_s.so{,.1} ${destdir}/usr/lib
ln -s /tools/lib/libstdc++.so{,.6} ${destdir}/usr/lib
sed 's/tools/usr/' /tools/lib/libstdc++.la >${destdir}/usr/lib/libstdc++.la
ln -s bash ${destdir}/bin/sh

ln -s /proc/self/mounts ${destdir}/etc/mtab

cat >${destdir}/etc/passwd <<"EOF"
root:x:0:0:root:/root:/bin/bash
bin:x:1:1:bin:/dev/null:/bin/false
daemon:x:6:6:Daemon User:/dev/null:/bin/false
messagebus:x:18:18:D-Bus Message Daemon User:/var/run/dbus:/bin/false
nobody:x:99:99:Unprivileged User:/dev/null:/bin/false
EOF

cat >${destdir}/etc/group <<"EOF"
root:x:0:
bin:x:1:daemon
sys:x:2:
kmem:x:3:
tape:x:4:
tty:x:5:
daemon:x:6:
floppy:x:7:
disk:x:8:
lp:x:9:
dialout:x:10:
audio:x:11:
video:x:12:
utmp:x:13:
usb:x:14:
cdrom:x:15:
adm:x:16:
messagebus:x:18:
systemd-journal:x:23:
input:x:24:
mail:x:34:
nogroup:x:99:
users:x:999:
EOF

exec /tools/bin/bash --login +h

touch ${destdir}/var/log/{btmp,lastlog,wtmp}
chgrp utmp ${destdir}/var/log/lastlog
chmod 664  ${destdir}/var/log/lastlog
chmod 600  ${destdir}/var/log/btmp
