#! /bin/bash

bindir=${HOME}/bin

# Section 5.4 Binutils-2.25.1 - Pass 1 http://www.linuxfromscratch.org/lfs/view/stable/chapter05/binutils-pass1.html

src_archive=sources/binutils-2.25.1.tar.bz2
source ${bindir}/build.sh
dist_archive=binutils-2.25.1-pass-1.tar.xz
configure_options="
--with-sysroot=${LFS}
--with-lib-path=${prefix}/lib
--target=${LFS_TGT}
--disable-nls
--disable-werror
"

unpack
configure
compile
package
install
clean

# Section 5.5. GCC-5.2.0 - Pass 1 http://www.linuxfromscratch.org/lfs/view/stable/chapter05/gcc-pass1.html

src_archive=sources/gcc-5.2.0.tar.bz2
source ${bindir}/build.sh
dist_archive=gcc-5.2.0-pass-1.tar.xz

post_unpack_gcc_pass1()
{
    tar -C ${srcdir} -xf ${sourcesdir}/mpfr-3.1.3.tar.xz
    mv ${srcdir}/mpfr-3.1.3 ${srcdir}/mpfr
    tar -C ${srcdir} -xf ${sourcesdir}/gmp-6.0.0a.tar.xz
    mv ${srcdir}/gmp-6.0.0 ${srcdir}/gmp
    tar -C ${srcdir} -xf ${sourcesdir}/mpc-1.0.3.tar.gz
    mv ${srcdir}/mpc-1.0.3 ${srcdir}/mpc
}

pre_configure_gcc_pass1()
{
    cd ${srcdir}

    for file in $(find gcc/config -name linux64.h -o -name linux.h -o -name sysv4.h); do
        cp -u ${file}{,.orig}
        sed -e "s@/lib\(64\)\?\(32\)\?/ld@${prefix}&@g" \
              -e "s@/usr@${prefix}@g" ${file}.orig >${file}
        echo "
#undef STANDARD_STARTFILE_PREFIX_1
#undef STANDARD_STARTFILE_PREFIX_2
#define STANDARD_STARTFILE_PREFIX_1 \"${prefix}/lib/\"
#define STANDARD_STARTFILE_PREFIX_2 \"\"" >>${file}
        touch ${file}.orig
    done
}

configure_options="
--target=${LFS_TGT}
--with-glibc-version=2.11
--with-sysroot=${LFS}
--with-newlib
--without-headers
--with-local-prefix=${prefix}
--with-native-system-header-dir=${prefix}/include
--disable-nls
--disable-shared
--disable-multilib
--disable-decimal-float
--disable-threads
--disable-libatomic
--disable-libgomp
--disable-libquadmath
--disable-libssp
--disable-libvtv
--disable-libstdcxx
--enable-languages=c,c++
"

unpack
post_unpack_gcc_pass1
pre_configure_gcc_pass1
configure
compile
package
install
clean

# Section 5.6. Linux-4.2 API Headers http://www.linuxfromscratch.org/lfs/view/stable/chapter05/linux-headers.html

src_archive=sources/linux-4.2.8.tar.xz
source ${bindir}/build.sh
dist_archive=linux-headers-4.2.8.tar.xz

pre_configure_linux_headers()
{
    make -C ${srcdir} mrproper
}

package_linux_headers()
{
    make -C ${srcdir} INSTALL_HDR_PATH=${destdir}${prefix} headers_install
    mkdir -p ${distdir}
    tar -C ${destdir} -caf ${distdir}/${dist_archive} .${prefix}
}

unpack
pre_configure_linux_headers
package_linux_headers
install
clean

# Section 5.7. Glibc-2.22 http://www.linuxfromscratch.org/lfs/view/stable/chapter05/glibc.html

src_archive=sources/glibc-2.22.tar.xz
source ${bindir}/build.sh
dist_archive=glibc-2.22.tar.xz

post_unpack_glibc()
{
    patch -d ${srcdir} -Np1 -i ${sourcesdir}/glibc-2.22-upstream_i386_fix-1.patch
}

configure_options="
--with-sysroot=${LFS}
--with-lib-path=${prefix}/lib
--target=${LFS_TGT}
--disable-nls
--disable-werror
"

post_build_glibc()
{
    echo 'int main(){}' > dummy.c
    ${LFS_TGT}-gcc dummy.c
    readelf -l a.out | grep ": ${prefix}"
    rm dummy.c a.out
}

unpack
post_unpack_glibc
configure
compile
package
install
clean
post_build_glibc

# Section 5.8. Libstdc++-5.2.0 http://www.linuxfromscratch.org/lfs/view/stable/chapter05/gcc-libstdc++.html

src_archive=sources/gcc-5.2.0.tar.bz2
source ${bindir}/build.sh
dist_archive=libstdc++-5.2.0.tar.xz

configure_options="
--host=${LFS_TGT}
--disable-multilib
--disable-nls
--disable-libstdcxx-threads
--disable-libstdcxx-pch
--with-gxx-include-dir=${prefix}/${LFS_TGT}/include/c++/5.2.0
"

unpack
srcdir=${srcdir}/libstdc++-v3 configure
compile
package
install
clean

# Section 5.9. Binutils-2.25.1 - Pass 2 http://www.linuxfromscratch.org/lfs/view/stable/chapter05/binutils-pass2.html

src_archive=sources/binutils-2.25.1.tar.bz2
source ${bindir}/build.sh
dist_archive=binutils-2.25.1-pass-2.tar.xz

configure_binutils_pass2()
{
    mkdir -p ${builddir}
    cd ${builddir}
    CC=${LFS_TGT}-gcc \
    AR=${LFS_TGT}-ar \
    RANLIB=${LFS_TGT}-ranlib \
    ${srcdir}/configure \
        --prefix=${prefix} \
        --with-sysroot \
        --with-lib-path=${prefix}/lib \
        --disable-nls \
        --disable-werror
}

post_package_binutils_pass2()
{
    make -C ${builddir}/ld clean
    make -C ${builddir}/ld LIB_PATH=/usr/lib:/lib
    cp ${builddir}/ld/ld-new ${destdir}${prefix}/bin
    tar -C ${destdir} -caf ${distdir}/${dist_archive} .${prefix}
}

unpack
configure_binutils_pass2
compile
package
post_package_binutils_pass2
install
clean

# Section 5.10. GCC-5.2.0 - Pass 2 http://www.linuxfromscratch.org/lfs/view/stable/chapter05/gcc-pass2.html

src_archive=sources/gcc-5.2.0.tar.bz2
source ${bindir}/build.sh
dist_archive=gcc-5.2.0-pass-2.tar.xz

post_unpack_gcc_pass2()
{
    tar -C ${srcdir} -xf ${sourcesdir}/mpfr-3.1.3.tar.xz
    mv ${srcdir}/mpfr-3.1.3 ${srcdir}/mpfr
    tar -C ${srcdir} -xf ${sourcesdir}/gmp-6.0.0a.tar.xz
    mv ${srcdir}/gmp-6.0.0 ${srcdir}/gmp
    tar -C ${srcdir} -xf ${sourcesdir}/mpc-1.0.3.tar.gz
    mv ${srcdir}/mpc-1.0.3 ${srcdir}/mpc
}

pre_configure_gcc_pass2()
{
    cd ${srcdir}

    cat gcc/limitx.h gcc/glimits.h gcc/limity.h > \
          $(dirname $($LFS_TGT-gcc -print-libgcc-file-name))/include-fixed/limits.h

    for file in $(find gcc/config -name linux64.h -o -name linux.h -o -name sysv4.h); do
        cp -u ${file}{,.orig}
        sed -e "s@/lib\(64\)\?\(32\)\?/ld@${prefix}&@g" \
              -e "s@/usr@${prefix}@g" ${file}.orig >${file}
        echo "
#undef STANDARD_STARTFILE_PREFIX_1
#undef STANDARD_STARTFILE_PREFIX_2
#define STANDARD_STARTFILE_PREFIX_1 \"${prefix}/lib/\"
#define STANDARD_STARTFILE_PREFIX_2 \"\"" >>${file}
        touch ${file}.orig
    done
}

configure_gcc_pass2()
{
    mkdir -p ${builddir}
    cd ${builddir}
    CC=${LFS_TGT}-gcc \
    CXX=${LFS_TGT}-g++ \
    AR=${LFS_TGT}-ar \
    RANLIB=${LFS_TGT}-ranlib \
    ${srcdir}/configure \
        --prefix=${prefix} \
        --with-local-prefix=${prefix} \
        --with-native-system-header-dir=${prefix}/include \
        --enable-languages=c,c++ \
        --disable-libstdcxx-pch \
        --disable-multilib \
        --disable-bootstrap \
        --disable-libgomp
}

post_build_gcc_pass2()
{
    echo 'int main(){}' > dummy.c
    gcc dummy.c
    readelf -l a.out | grep ": ${prefix}"
    rm dummy.c a.out
}

unpack
post_unpack_gcc_pass2
pre_configure_gcc_pass2
configure_gcc_pass2
compile
package
install
clean
post_build_gcc_pass2

# Section 5.11. Tcl-core-8.6.4 http://www.linuxfromscratch.org/lfs/view/stable/chapter05/tcl.html

src_archive=sources/tcl-core8.6.4-src.tar.gz
source ${bindir}/build.sh
dist_archive=tcl-core-8.6.4.tar.xz

test_build_tcl_core()
{
    TC=UTC make -C ${builddir} test
}

pre_package_tcl_core()
{
    make -C ${builddir} DESTDIR=${destdir} install-private-headers
    mkdir -p ${destdir}${prefix}/bin
    ln -s tclsh8.6 ${destdir}${prefix}/bin/tclsh
}

unpack
srcdir=${srcdir}/unix configure
compile
test_build_tcl_core
pre_package_tcl_core
package
install
clean

# Section 5.12. Expect-5.45 http://www.linuxfromscratch.org/lfs/view/stable/chapter05/expect.html

src_archive=sources/expect5.45.tar.gz
source ${bindir}/build.sh
dist_archive=expect-5.45.tar.xz

configure_options="
--with-tcl=${prefix}/lib
--with-tclinclude=${prefix}/include
"

package_expect()
{
    if test $(uname -m) = x86_64 -a ! -L ${destdir}${prefix}/lib64; then
        mkdir -p ${destdir}${prefix}
        ln -s lib ${destdir}${prefix}/lib64
    fi

    make -C ${builddir} DESTDIR=${destdir} SCRIPTS="" install
    mkdir -p ${distdir}
    tar -C ${destdir} -caf ${distdir}/${dist_archive} .${prefix}
}

unpack
configure
compile
test_build
package_expect
install
clean

# Section 5.13. DejaGNU-1.5.3 http://www.linuxfromscratch.org/lfs/view/stable/chapter05/dejagnu.html

src_archive=sources/dejagnu-1.5.3.tar.gz
source ${bindir}/build.sh
dist_archive=dejagnu-1.5.3.tar.xz

unpack
configure
compile
test_build check
package
install
clean

# Section 5.14 Check-0.10.0 http://www.linuxfromscratch.org/lfs/view/stable/chapter05/check.html

src_archive=sources/check-0.10.0.tar.gz
source ${bindir}/build.sh
dist_archive=check-0.10.0.tar.xz

unpack
PKG_CONFIG= configure
compile
test_build check
package
install
clean

# Section 5.15. Ncurses-6.0 http://www.linuxfromscratch.org/lfs/view/stable/chapter05/ncurses.html

src_archive=sources/ncurses-6.0.tar.gz
source ${bindir}/build.sh
dist_archive=ncurses-6.0.tar.xz

pre_configure_ncurses()
{
    sed -i s/mawk// ${srcdir}/configure
}

configure_options="
--with-shared
--without-debug
--without-ada
--enable-widec
--enable-overwrite
"

test_build_ncurses()
{
    make -C ${builddir}/test
}

unpack
pre_configure_ncurses
configure
compile
package
install
test_build_ncurses
clean

# Section 5.16. Bash-4.3.30 http://www.linuxfromscratch.org/lfs/view/stable/chapter05/bash.html

src_archive=sources/bash-4.3.30.tar.gz
source ${bindir}/build.sh
dist_archive=bash-4.3.30.tar.xz

configure_options=--without-bash-malloc

pre_package_bash()
{
    mkdir -p ${destdir}${prefix}/bin
    ln -s bash ${destdir}${prefix}/bin/sh
}

unpack
configure
compile
test_build tests
pre_package_bash
package
install
clean

# Section 5.17. Bzip2-1.0.6 http://www.linuxfromscratch.org/lfs/view/stable/chapter05/bzip2.html

src_archive=sources/bzip2-1.0.6.tar.gz
source ${bindir}/build.sh
dist_archive=bzip2-1.0.6.tar.xz
builddir=${srcdir}

pre_package_bzip2()
{
    sed -i -e '/ln -s -f/s,\$(PREFIX)/bin/,,' ${srcdir}/Makefile
}

package_bzip2()
{
    if test $(uname -m) = x86_64 -a ! -L ${destdir}${prefix}/lib64; then
        mkdir -p ${destdir}${prefix}
        ln -s lib ${destdir}${prefix}/lib64
    fi

    make -C ${builddir} PREFIX=${destdir}${prefix} install
    mkdir -p ${distdir}
    tar -C ${destdir} -caf ${distdir}/${dist_archive} .${prefix}
}

unpack
compile
pre_package_bzip2
package_bzip2
install
clean

# Section 5.18. Coreutils-8.24 http://www.linuxfromscratch.org/lfs/view/stable/chapter05/coreutils.html

src_archive=sources/coreutils-8.24.tar.xz
source ${bindir}/build.sh
dist_archive=coreutils-8.24.tar.xz

configure_options=--enable-install-program=hostname

unpack
configure
compile
test_build RUN_EXPENSIVE_TESTS=yes check
package
install
clean

# Section 5.19. Diffutils-3.3 http://www.linuxfromscratch.org/lfs/view/stable/chapter05/diffutils.html

src_archive=sources/diffutils-3.3.tar.xz
source ${bindir}/build.sh
dist_archive=diffutils-3.3.tar.xz

unpack
configure
compile
test_build check
package
install
clean

# Section 5.20. File-5.24 http://www.linuxfromscratch.org/lfs/view/stable/chapter05/file.html

src_archive=sources/file-5.24.tar.gz
source ${bindir}/build.sh
dist_archive=file-5.24.tar.xz

unpack
configure
compile
test_build check
package
install
clean

# Section 5.21. Findutils-4.4.2 http://www.linuxfromscratch.org/lfs/view/stable/chapter05/findutils.html

src_archive=sources/findutils-4.4.2.tar.gz
source ${bindir}/build.sh
dist_archive=findutils-4.4.2.tar.xz

unpack
configure
compile
test_build check
package
install
clean

# Section 5.22. Gawk-4.1.3 http://www.linuxfromscratch.org/lfs/view/stable/chapter05/gawk.html

src_archive=sources/gawk-4.1.3.tar.xz
source ${bindir}/build.sh
dist_archive=gawk-4.1.3.tar.xz

unpack
configure
compile
# FIXME How do I make sure, test doesn't block in case of failure
test_build check
package
install
clean

# Section 5.23. Gettext-0.19.5.1 http://www.linuxfromscratch.org/lfs/view/stable/chapter05/gettext.html

src_archive=sources/gettext-0.19.5.1.tar.xz
source ${bindir}/build.sh
dist_archive=gettext-0.19.5.1.tar.xz

configure_gettext()
{
    mkdir -p ${builddir}/gettext-tools
    cd ${builddir}/gettext-tools
    EMACS=no ${srcdir}/gettext-tools/configure \
        --prefix=${prefix} \
        --disable-shared
}

compile_gettext()
{
    make -C ${builddir}/gettext-tools/gnulib-lib
    make -C ${builddir}/gettext-tools/intl pluralx.c
    make -C ${builddir}/gettext-tools/src msgfmt msgmerge xgettext
}

package_gettext()
{
    mkdir -p ${destdir}${prefix}/bin
    cp ${builddir}/gettext-tools/src/{msgfmt,msgmerge,xgettext} ${destdir}${prefix}/bin
    mkdir -p ${distdir}
    tar -C ${destdir} -caf ${distdir}/${dist_archive} .${prefix}
}

unpack
configure_gettext
compile_gettext
package_gettext
install
clean

# Section 5.24. Grep-2.21 http://www.linuxfromscratch.org/lfs/view/stable/chapter05/grep.html

src_archive=sources/grep-2.21.tar.xz
source ${bindir}/build.sh
dist_archive=grep-2.21.tar.xz

unpack
configure
compile
test_build check
package
install
clean

# Section 5.25. Gzip-1.6 http://www.linuxfromscratch.org/lfs/view/stable/chapter05/gzip.html

src_archive=sources/gzip-1.6.tar.xz
source ${bindir}/build.sh
dist_archive=gzip-1.6.tar.xz

unpack
configure
compile
test_build check
package
install
clean

# Section 5.26. M4-1.4.17 http://www.linuxfromscratch.org/lfs/view/stable/chapter05/m4.html

src_archive=sources/m4-1.4.17.tar.xz
source ${bindir}/build.sh
dist_archive=m4-1.4.17.tar.xz

unpack
configure
compile
test_build check
package
install
clean

# Section 5.27. Make-4.1 http://www.linuxfromscratch.org/lfs/view/stable/chapter05/make.html

src_archive=sources/make-4.1.tar.bz2
source ${bindir}/build.sh
dist_archive=make-4.1.tar.xz

configure_options=--without-guile

unpack
configure
compile
test_build check
package
install
clean

# Section 5.28. Patch-2.7.5 http://www.linuxfromscratch.org/lfs/view/stable/chapter05/patch.html

src_archive=sources/patch-2.7.5.tar.xz
source ${bindir}/build.sh
dist_archive=patch-2.7.5.tar.xz

unpack
configure
compile
test_build check
package
install
clean

# Section 5.29. Perl-5.22.0 http://www.linuxfromscratch.org/lfs/view/stable/chapter05/perl.html

src_archive=sources/perl-5.22.0.tar.bz2
source ${bindir}/build.sh
dist_archive=perl-5.22.0.tar.xz
builddir=${srcdir}

configure_perl()
{
    mkdir -p ${builddir}
    cd ${builddir}
    sh ${srcdir}/Configure \
        -des \
        -Dprefix=${prefix} \
        -Dlibs=-lm
}

package_perl()
{
    mkdir -p ${destdir}${prefix}/bin ${destdir}${prefix}/lib/perl5/5.22.0
    cp ${builddir}/perl ${builddir}/cpan/podlators/pod2man ${destdir}${prefix}/bin
    cp -R ${builddir}/lib/* ${destdir}${prefix}/lib/perl5/5.22.0

    mkdir -p ${distdir}
    tar -C ${destdir} -caf ${distdir}/${dist_archive} .${prefix}
}

unpack
configure_perl
compile
package_perl
install
clean

# Section 5.30. Sed-4.2.2 http://www.linuxfromscratch.org/lfs/view/stable/chapter05/sed.html

src_archive=sources/sed-4.2.2.tar.bz2
source ${bindir}/build.sh
dist_archive=sed-4.2.2.tar.xz

unpack
configure
compile
test_build check
package
install
clean

# Section 5.31. Tar-1.28 http://www.linuxfromscratch.org/lfs/view/stable/chapter05/tar.html

src_archive=sources/tar-1.28.tar.xz
source ${bindir}/build.sh
dist_archive=tar-1.28.tar.xz

unpack
configure
compile
test_build check
package
install
clean

# Section 5.32. Texinfo-6.0 http://www.linuxfromscratch.org/lfs/view/stable/chapter05/texinfo.html

src_archive=sources/texinfo-6.0.tar.xz
source ${bindir}/build.sh
dist_archive=texinfo-6.0.tar.xz

unpack
configure
compile
test_build check
package
install
clean

# Section 5.33. Util-linux-2.27 http://www.linuxfromscratch.org/lfs/view/stable/chapter05/util-linux.html

src_archive=sources/util-linux-2.27.tar.xz
source ${bindir}/build.sh
dist_archive=util-linux-2.27.tar.xz

configure_options='
--without-python
--disable-makeinstall-chown
--without-systemdsystemunitdir
PKG_CONFIG=""
'

unpack
configure
compile
package
install
clean

# Section 5.34. Xz-5.2.1 http://www.linuxfromscratch.org/lfs/view/stable/chapter05/xz.html

src_archive=sources/xz-5.2.1.tar.xz
source ${bindir}/build.sh
dist_archive=xz-5.2.1.tar.xz

unpack
configure
compile
test_build check
package
install
clean
