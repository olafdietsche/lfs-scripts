#! /bin/sh

# Section 4.2 http://www.linuxfromscratch.org/lfs/view/stable/chapter04/creatingtoolsdir.html

lfs_tools_dir=${targetdir}/tools
mkdir -p ${lfs_tools_dir}
su -c "ln -s ${lfs_tools_dir} /"

# Section 4.3 http://www.linuxfromscratch.org/lfs/view/stable/chapter04/addinguser.html

#groupadd lfs
#useradd -s /bin/bash -g lfs -m -k /dev/null lfs
#passwd lfs
#chown lfs ${lfs_tools_dir}
#chown lfs ${sourcesdir}
#su - lfs
