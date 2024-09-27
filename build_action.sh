#!/usr/bin/env bash

# Function to download and extract Linux kernel source
download_and_extract() {
    local version=$1
    local url=$2

    wget "$url"
    
    if [[ -f linux-"$version".tar.xz ]]; then
        tar -xvf linux-"$version".tar.xz
    elif [[ -f linux-"$version".tar.gz ]]; then
        tar -xvf linux-"$version".tar.gz
    elif [[ -f linux-"$version".tar ]]; then
        tar -xvf linux-"$version".tar
    elif [[ -f linux-"$version".bz2 ]]; then
        tar -xvf linux-"$version".tar.bz2
    fi
    
    cd linux-"$version" || exit
}

# Function to configure the kernel
configure_kernel() {
    cp ../config .config
    
    scripts/config --disable DEBUG_INFO_X86 \
                   --disable DEBUG_INFO_VMCORE \
                   --disable DEBUG_INFO_SPLIT \
                   --disable DEBUG_INFO_BTF_MODULES \
                   --disable DEBUG_INFO_DWARF_TOOLCHAIN_DEFAULT \
                   --disable DEBUG_INFO_PERF \
                   --disable DEBUG_INFO_BTF \
                   --disable DEBUG_INFO_DWARF4 \
                   --disable DEBUG_INFO_REDUCED \
                   --set-str SYSTEM_TRUSTED_KEYS "" \
                   --set-str SYSTEM_REVOCATION_KEYS "" \
                   --undefine DEBUG_INFO \
                   --undefine DEBUG_INFO_COMPRESSED \
                   --undefine DEBUG_INFO_REDUCED \
                   --undefine DEBUG_INFO_SPLIT \
                   --undefine GDB_SCRIPTS \
                   --set-val DEBUG_INFO_DWARF5 n \
                   --set-val DEBUG_INFO_NONE y
}

# Function to build the kernel package
build_kernel() {
    local cpu_cores=$(($(grep -c processor < /proc/cpuinfo) * 2))
    sudo make bindeb-pkg -j"$cpu_cores"
    cd .. 
}

# Mainline, Stable, Longterm versions setup
versions=("mainline" "stable")
for version in "${versions[@]}"; do
    url_var="${version}url"
    version_var="$version"

    version=$(cat /tmp/"$version_var".txt)
    url=$(cat /tmp/"$url_var".txt)
    
    download_and_extract "$version" "$url"
    configure_kernel
    build_kernel
done

# Optional: Uncomment this to handle longterm version
:<<EOF
longterm=$(cat /tmp/longterm.txt)
longtermurl=$(cat /tmp/longtermurl.txt)

download_and_extract "$longterm" "$longtermurl"
configure_kernel
build_kernel
EOF

# Create artifact directory and clean up
mkdir -p artifact
rm -rfv *dbg*.deb
mv ./*.deb artifact/
sudo bash Install-deb.sh
