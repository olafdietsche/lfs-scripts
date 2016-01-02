#! /bin/sh

# Section 4.2 http://www.linuxfromscratch.org/lfs/view/stable/chapter04/creatingtoolsdir.html

lfs_tools_dir=$LFS/tools
mkdir -p ${lfs_tools_dir}
su -c "ln -s ${lfs_tools_dir} /"

# Section 4.3 http://www.linuxfromscratch.org/lfs/view/stable/chapter04/addinguser.html

#groupadd lfs
#useradd -s /bin/bash -g lfs -m -k /dev/null lfs
#passwd lfs
#chown lfs $LFS/tools
#chown lfs $LFS/sources
#su - lfs
