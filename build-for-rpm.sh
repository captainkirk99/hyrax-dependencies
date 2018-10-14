#!/bin/sh
#
# Build the hyrax-dependencies binary tar ball for use with libdap and BES 
# RPM builds

set -eux

df -h
printenv

# git
# emacs 
# vim 
# bc
# rpm-devel 
# rpm-build 
# redhat-rpm-config

PACKAGES="
gcc-c++ 
flex 
bison 
autoconf 
automake 
libtool
cmake 
openssl-devel 
libuuid-devel 
readline-devel 
libxml2-devel 
curl-devel 
zlib-devel 
bzip2 
bzip2-devel 
libjpeg-devel 
libicu-devel 
"

yum -y install $PACKAGES

make -j4 for-static-rpm
 