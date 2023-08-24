#!/usr/bin/env bash


sudo apt update
sudo apt install gpg python3-pyquery -y

python3 get-newest-version.py 0
python3 get-newest-version.py 1
python3 get-newest-version.py 2
mainline=`cat /tmp/mainline.txt`
mainlineurl=`cat /tmp/mainlineurl.txt`
MAINVERSION=`expr substr mainline 1 1`
SHOWVERSION=mainline

# add deb-src to sources.list
sed -i "/deb-src/s/# //g" /etc/apt/sources.list

# install dep
sudo apt update
sudo apt install -y wget xz-utils make gcc flex bison dpkg-dev bc rsync kmod cpio libssl-dev git lsb vim libelf-dev neofetch python3-pip python3-tk debhelper
pip3 install requests wget ttkthemes

sudo apt build-dep -y linux
neofetch


# change dir to workplace
cd "${GITHUB_WORKSPACE}" || exit

wget $mainlineurl
if [[ -f linux-"$mainline".tar.xz ]]; then
    tar -xvf linux-"$mainline".tar.xz
fi
if [[ -f linux-"$mainline".tar.gz ]]; then
    tar -xvf linux-"$mainline".tar.gz
fi
if [[ -f linux-"$mainline".tar ]]; then
    tar -xvf linux-"$mainline".tar
fi
if [[ -f linux-"$mainline".bz2 ]]; then
    tar -xvf linux-"$mainline".tar.bz2
fi
cd linux-"$mainline" || exit



# download kernel source
# wget http://www.kernel.org/pub/linux/kernel/v6.x/linux-6.4.tar.gz  
# tar -xf linux-"$VERSION".tar.gz
# cd linux-"$VERSION" || exit

# copy config file
cp ../config .config
#
# disable DEBUG_INFO to speedup build
# scripts/config --disable DEBUG_INFO 
scripts/config --disable DEBUG_INFO_X86
scripts/config --disable DEBUG_INFO_VMCORE
scripts/config --disable DEBUG_INFO_SPLIT
scripts/config --disable DEBUG_INFO_BTF_MODULES
scripts/config --disable DEBUG_INFO_DWARF_TOOLCHAIN_DEFAULT
scripts/config --disable DEBUG_INFO_PERF
scripts/config --disable DEBUG_INFO_BTF
scripts/config --disable DEBUG_INFO_DWARF4
scripts/config --disable DEBUG_INFO_REDUCED
scripts/config --set-str SYSTEM_TRUSTED_KEYS "" 
scripts/config --set-str SYSTEM_REVOCATION_KEYS "" 
scripts/config --undefine DEBUG_INFO 
scripts/config --undefine DEBUG_INFO_COMPRESSED 
scripts/config --undefine DEBUG_INFO_REDUCED 
scripts/config --undefine DEBUG_INFO_SPLIT 
scripts/config --undefine GDB_SCRIPTS 
scripts/config --set-val DEBUG_INFO_DWARF5 n 
scripts/config --set-val DEBUG_INFO_NONE y 
# apply patches
# shellcheck source=src/util.sh
# source ../patch.d/*.sh



# build deb packages
CPU_CORES=$(($(grep -c processor < /proc/cpuinfo)*2))
sudo make bindeb-pkg -j"$CPU_CORES"

# move deb packages to artifact dir
cd ..


stable=`cat /tmp/stable.txt`

# change dir to workplace
cd "${GITHUB_WORKSPACE}" || exit

stableurl=`cat /tmp/stableurl.txt`

wget $stableurl    
if [[ -f linux-"$stable".tar.xz ]]; then
    tar -xvf linux-"$stable".tar.xz
fi
if [[ -f linux-"$stable".tar.gz ]]; then
    tar -xvf linux-"$stable".tar.gz
fi
if [[ -f linux-"$stable".tar ]]; then
    tar -xvf linux-"$stable".tar
fi
if [[ -f linux-"$stable".bz2 ]]; then
    tar -xvf linux-"$stable".tar.bz2
fi
cd linux-"$stable" || exit


# copy config file
cp ../config .config
#
# disable DEBUG_INFO to speedup build
# scripts/config --disable DEBUG_INFO 
scripts/config --disable DEBUG_INFO_X86
scripts/config --disable DEBUG_INFO_VMCORE
scripts/config --disable DEBUG_INFO_SPLIT
scripts/config --disable DEBUG_INFO_BTF_MODULES
scripts/config --disable DEBUG_INFO_DWARF_TOOLCHAIN_DEFAULT
scripts/config --disable DEBUG_INFO_PERF
scripts/config --disable DEBUG_INFO_BTF
scripts/config --disable DEBUG_INFO_DWARF4
scripts/config --disable DEBUG_INFO_REDUCED
scripts/config --set-str SYSTEM_TRUSTED_KEYS "" 
scripts/config --set-str SYSTEM_REVOCATION_KEYS "" 
scripts/config --undefine DEBUG_INFO 
scripts/config --undefine DEBUG_INFO_COMPRESSED 
scripts/config --undefine DEBUG_INFO_REDUCED 
scripts/config --undefine DEBUG_INFO_SPLIT 
scripts/config --undefine GDB_SCRIPTS 
scripts/config --set-val DEBUG_INFO_DWARF5 n 
scripts/config --set-val DEBUG_INFO_NONE y 

# build deb packages
CPU_CORES=$(($(grep -c processor < /proc/cpuinfo)*2))
sudo make bindeb-pkg -j"$CPU_CORES"

# move deb packages to artifact dir
cd ..


longterm=`cat /tmp/longterm.txt`

# change dir to workplace
cd "${GITHUB_WORKSPACE}" || exit

longtermurl=`cat /tmp/longtermurl.txt`

wget $longtermurl   
if [[ -f linux-"$longterm".tar.xz ]]; then
    tar -xvf linux-"$longterm".tar.xz
fi
if [[ -f linux-"$longterm".tar.gz ]]; then
    tar -xvf linux-"$longterm".tar.gz
fi
if [[ -f linux-"$longterm".tar ]]; then
    tar -xvf linux-"$longterm".tar
fi
if [[ -f linux-"$longterm".bz2 ]]; then
    tar -xvf linux-"$longterm".tar.bz2
fi
cd linux-"$longterm" || exit


# copy config file
cp ../config .config
#
# disable DEBUG_INFO to speedup build
# scripts/config --disable DEBUG_INFO 
scripts/config --disable DEBUG_INFO_X86
scripts/config --disable DEBUG_INFO_VMCORE
scripts/config --disable DEBUG_INFO_SPLIT
scripts/config --disable DEBUG_INFO_BTF_MODULES
scripts/config --disable DEBUG_INFO_DWARF_TOOLCHAIN_DEFAULT
scripts/config --disable DEBUG_INFO_PERF
scripts/config --disable DEBUG_INFO_BTF
scripts/config --disable DEBUG_INFO_DWARF4
scripts/config --disable DEBUG_INFO_REDUCED
scripts/config --set-str SYSTEM_TRUSTED_KEYS "" 
scripts/config --set-str SYSTEM_REVOCATION_KEYS "" 
scripts/config --undefine DEBUG_INFO 
scripts/config --undefine DEBUG_INFO_COMPRESSED 
scripts/config --undefine DEBUG_INFO_REDUCED 
scripts/config --undefine DEBUG_INFO_SPLIT 
scripts/config --undefine GDB_SCRIPTS 
scripts/config --set-val DEBUG_INFO_DWARF5 n 
scripts/config --set-val DEBUG_INFO_NONE y 

# build deb packages
CPU_CORES=$(($(grep -c processor < /proc/cpuinfo)*2))
sudo make bindeb-pkg -j"$CPU_CORES"

# move deb packages to artifact dir
cd ..


mkdir "artifact"
mkdir kernel/$SHOWVERSION
rm -rfv *dbg*.deb
mv ./*.deb kernel/$SHOWVERSION
cd kernel/$SHOWVERSION
#mv ./* ../artifact/
mv ./*.deb artifact/
