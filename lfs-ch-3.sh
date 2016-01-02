#! /bin/sh

# Section 3.1 http://www.linuxfromscratch.org/lfs/view/stable/chapter03/introduction.html

lfs_sources_dir=$LFS/sources
mkdir -p ${lfs_sources_dir}

wget_options="--timestamping --continue --directory-prefix=${lfs_sources_dir} --tries=1 --no-verbose"
wget ${wget_options} http://www.linuxfromscratch.org/lfs/view/stable/wget-list
wget --input-file=$LFS/sources/wget-list ${wget_options}
wget ${wget_options} http://www.linuxfromscratch.org/lfs/view/stable/md5sums

pushd ${lfs_sources_dir}
md5sum --check --quiet md5sums
popd
