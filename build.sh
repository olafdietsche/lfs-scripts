#! /bin/bash

top=$(readlink -f .)
targetdir=${targetdir:-${LFS}}
workdir=${workdir:-${top}}
prefix=${prefix:-/tools}
sourcesdir=${workdir}/sources
srcdir=${workdir}/src
#src_archive=
distdir=${workdir}/dist
dist_archive=$(basename ${src_archive})
builddir=${workdir}/build
destdir=${workdir}/dest

# To run tests, comment next line or redefine empty, e.g. cmd_skip_test=
cmd_skip_test=:

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
    ${cmd_skip_test} make -C ${builddir} ${@:-test}
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
	tar -C ${targetdir} -xf ${distdir}/${dist_archive}
}

clean()
{
    cd ${workdir}
	rm -rf ${srcdir} ${builddir} ${destdir}
}
