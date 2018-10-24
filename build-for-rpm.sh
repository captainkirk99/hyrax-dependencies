#!/bin/sh
#
# Build the hyrax-dependencies binary tar ball for use with libdap and BES 
# RPM builds. Uses the opendap/centos6_hyrax_builder:latest docker container
# (or the CentOS7 version).

set -eu

printenv

(cd /root/hyrax-dependencies && make -j4 for-static-rpm)
 
