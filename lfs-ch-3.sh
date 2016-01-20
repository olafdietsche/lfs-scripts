#! /bin/sh

# Section 3.1 http://www.linuxfromscratch.org/lfs/view/stable/chapter03/introduction.html

mkdir -p ${sourcesdir}

wget_options="--timestamping --continue --directory-prefix=${sourcesdir} --tries=1 --no-verbose"
wget ${wget_options} http://www.linuxfromscratch.org/lfs/view/stable/wget-list
wget --input-file=${sourcesdir}/wget-list ${wget_options}
wget ${wget_options} http://www.linuxfromscratch.org/lfs/view/stable/md5sums

pushd ${sourcesdir}
md5sum --check --quiet md5sums
popd
