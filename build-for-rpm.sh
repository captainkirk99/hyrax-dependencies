#!/bin/sh
#
# Build the hyrax-dependencies binary tar ball for use with libdap and BES 
# RPM builds. Uses the opendap/centos6_hyrax_builder:latest docker container
# (or the CentOS7 version).
#
# Modified to take an optional parameter that denotes the version of the C++
# compiler to use. Since C6 lacks a C++-11 compiler, this can be used to supress
# building some of the dependencies. jhrg 10/28/19

# -e: Exit imediately if a command, command in a pipeline, etc., fails
# -u: Treat unset variables in substitutions as errors (except for @ and *)
set -eu

if test -z "$1" -a x"$1" = "xstare" -o x"$1" = "xSTARE"
then
  export BUILD_STARE=yes
fi

(cd /root/hyrax-dependencies && make -j4 for-static-rpm)
