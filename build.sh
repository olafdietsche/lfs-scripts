#! /bin/bash

top=$(readlink -f .)
prefix=/tools
sourcesdir=${top}/sources
srcdir=${top}/src
#src_archive=
distdir=${top}/dist
dist_archive=$(basename ${src_archive})
builddir=${top}/build
destdir=${top}/dest

usage()
{
	echo "usage: [unpack|configure|compile|package|install|clean]"
}

all()
{
    unpack
    configure
    compile
    test_build
    package
    install
    clean
}

unpack()
{
	mkdir -p ${srcdir}
	tar -C ${srcdir} --strip-components=1 --keep-old-files --skip-old-files -xf ${src_archive}
}

configure()
{
	mkdir -p ${builddir}
	cd ${builddir}
	${srcdir}/configure \
		--prefix=${prefix} \
		${configure_options}
}

compile()
{
	make -C ${builddir}
}

test_build()
{
    make -C ${builddir} ${@:-test}
}

package()
{
	if test $(uname -m) = x86_64 -a ! -L ${destdir}${prefix}/lib64; then
        mkdir -p ${destdir}${prefix}
        ln -s lib ${destdir}${prefix}/lib64
    fi

	make -C ${builddir} DESTDIR=${destdir} install
	mkdir -p ${distdir}
	tar -C ${destdir} -caf ${distdir}/${dist_archive} .${prefix}
}

install()
{
	tar -C ${LFS} -xf ${distdir}/${dist_archive}
}

clean()
{
    cd ${top}
	rm -rf ${srcdir} ${builddir} ${destdir}
}
