#! /bin/sh

bindir=${HOME}/bin

# Section 5.4 Binutils-2.25.1 - Pass 1 http://www.linuxfromscratch.org/lfs/view/stable/chapter05/binutils-pass1.html

src_archive=sources/binutils-2.25.1.tar.bz2
source ${bindir}/build.sh
dist_archive=binutils-2.25.1-pass-1.tar.xz

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

post_unpack()
{
    tar -C ${srcdir} -xf ${sourcesdir}/mpfr-3.1.3.tar.xz
    mv ${srcdir}/mpfr-3.1.3 ${srcdir}/mpfr
    tar -C ${srcdir} -xf ${sourcesdir}/gmp-6.0.0a.tar.xz
    mv ${srcdir}/gmp-6.0.0 ${srcdir}/gmp
    tar -C ${srcdir} -xf ${sourcesdir}/mpc-1.0.3.tar.gz
    mv ${srcdir}/mpc-1.0.3 ${srcdir}/mpc
}

pre_configure()
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

configure()
{
	mkdir -p ${builddir}
	cd ${builddir}
    ${srcdir}/configure \
        --target=${LFS_TGT} \
        --prefix=${prefix} \
        --with-glibc-version=2.11 \
        --with-sysroot=${LFS} \
        --with-newlib \
        --without-headers \
        --with-local-prefix=${prefix} \
        --with-native-system-header-dir=${prefix}/include \
        --disable-nls \
        --disable-shared \
        --disable-multilib \
        --disable-decimal-float \
        --disable-threads \
        --disable-libatomic \
        --disable-libgomp \
        --disable-libquadmath \
        --disable-libssp \
        --disable-libvtv \
        --disable-libstdcxx \
        --enable-languages=c,c++
}

unpack
post_unpack
pre_configure
configure
compile
package
install
clean

# Section 5.6. Linux-4.2 API Headers http://www.linuxfromscratch.org/lfs/view/stable/chapter05/linux-headers.html

src_archive=sources/linux-4.2.8.tar.xz
source ${bindir}/build.sh
dist_archive=linux-headers-4.2.8.tar.xz

pre_configure()
{
    make -C ${srcdir} mrproper
}

package()
{
    make -C ${srcdir} INSTALL_HDR_PATH=${destdir}/${prefix} headers_install
    mkdir -p ${distdir}
    tar -C ${destdir} -caf ${distdir}/${dist_archive} ./${prefix/#\//}
}

unpack
pre_configure
package
install
clean

# Section 5.7. Glibc-2.22 http://www.linuxfromscratch.org/lfs/view/stable/chapter05/glibc.html

src_archive=sources/glibc-2.22.tar.xz
source ${bindir}/build.sh
dist_archive=glibc-2.22.tar.xz

post_unpack()
{
    patch -d ${srcdir} -Np1 -i ${sourcesdir}/glibc-2.22-upstream_i386_fix-1.patch
}

configure()
{
    mkdir -p ${builddir}
    cd ${builddir}
    ${srcdir}/configure \
        --prefix=${prefix} \
        --with-sysroot=${LFS} \
        --with-lib-path=${prefix}/lib \
        --target=${LFS_TGT} \
        --disable-nls \
        --disable-werror
}

post_build()
{
    echo 'int main(){}' > dummy.c
    ${LFS_TGT}-gcc dummy.c
    readelf -l a.out | grep ": ${prefix}"
    rm dummy.c a.out
}

unpack
post_unpack
configure
compile
package
install
clean
post_build

# Section 5.8. Libstdc++-5.2.0 http://www.linuxfromscratch.org/lfs/view/stable/chapter05/gcc-libstdc++.html

src_archive=sources/gcc-5.2.0.tar.bz2
source ${bindir}/build.sh
dist_archive=libstdc++-5.2.0.tar.xz

configure()
{
    mkdir -p ${builddir}
    cd ${builddir}
    ${srcdir}/libstdc++-v3/configure \
        --host=${LFS_TGT} \
        --prefix=${prefix} \
        --disable-multilib \
        --disable-nls \
        --disable-libstdcxx-threads \
        --disable-libstdcxx-pch \
        --with-gxx-include-dir=${prefix}/${LFS_TGT}/include/c++/5.2.0
}

unpack
configure
compile
package
install
clean

# Section 5.9. Binutils-2.25.1 - Pass 2 http://www.linuxfromscratch.org/lfs/view/stable/chapter05/binutils-pass2.html

src_archive=sources/binutils-2.25.1.tar.bz2
source ${bindir}/build.sh
dist_archive=binutils-2.25.1-pass-2.tar.xz

configure()
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

post_package()
{
    make -C ${builddir}/ld clean
    make -C ${builddir}/ld LIB_PATH=/usr/lib:/lib
    cp ${builddir}/ld/ld-new ${destdir}/${prefix}/bin
    tar -C ${destdir} -caf ${distdir}/${dist_archive} ./${prefix/#\//}
}

unpack
configure
compile
package
post_package
install
clean

# Section 5.10. GCC-5.2.0 - Pass 2 http://www.linuxfromscratch.org/lfs/view/stable/chapter05/gcc-pass2.html

src_archive=sources/gcc-5.2.0.tar.bz2
source ${bindir}/build.sh
dist_archive=gcc-5.2.0-pass-2.tar.xz

post_unpack()
{
    tar -C ${srcdir} -xf ${sourcesdir}/mpfr-3.1.3.tar.xz
    mv ${srcdir}/mpfr-3.1.3 ${srcdir}/mpfr
    tar -C ${srcdir} -xf ${sourcesdir}/gmp-6.0.0a.tar.xz
    mv ${srcdir}/gmp-6.0.0 ${srcdir}/gmp
    tar -C ${srcdir} -xf ${sourcesdir}/mpc-1.0.3.tar.gz
    mv ${srcdir}/mpc-1.0.3 ${srcdir}/mpc
}

pre_configure()
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

configure()
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

post_build()
{
    echo 'int main(){}' > dummy.c
    gcc dummy.c
    readelf -l a.out | grep ": ${prefix}"
    rm dummy.c a.out
}

unpack
post_unpack
pre_configure
configure
compile
package
install
clean
post_build
