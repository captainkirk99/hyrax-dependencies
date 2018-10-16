# Build a machine that can compile the hyrax-dependencies, libdap4 and BES.
# This is designed to work with Travis CI and will need to have some volumes
# for input and output mounted and then a script run to run the build.
#
# Build the docker container using
#
# docker build -t <catchy name> .
#
# The 'docker run' command would look something like:
#
# docker run --volume $HOME/install/centos6:/home/install
# --volume $TRAVIS_BUILD_DIR:/home/hyrax-dependencies 
# opendap/centos6_hyrax_builder:latest /home/hyrax-dependencies/build-for-rpm.sh
#
# Where $HOME/install is the value of prefix for the Travis CI build of
# hyrax-dependencies, $TRAVIS_BUILD_DIR hows the cloned hyeax-dependencies repo
#
# Then push the docker container up to the docker hub
#
# docker login [use opendap's creds]
# docker tag centos6_hyrax_builder opendap/centos6_hyrax_builder:latest
# docker push opendap/centos6_hyrax_builder:latest 
# 
# Use an official CentOS6 or 7 runtime as a parent image
# FROM centos:centos6
# FROM centos:centos7
# Use this is you need to 'repair' an existing container: FROM centos7_hyrax_builder
FROM opendap/centos6_hyrax_builder:latest

# Set the working directory to /home; not needed. Once started, the /home/hyrax-dep...
# dir will be made by the --volume option used with docker run. That's where the 
# build sources will be found. But at this point, that directory does not exist.
WORKDIR /root

# Install any needed packages specified in requirements.txt
RUN yum -y install gcc-c++ make cmake git flex bison autoconf automake libtool bc
RUN yum -y install openssl-devel libuuid-devel readline-devel libxml2-devel curl-devel libicu-devel
RUN yum -y install zlib-devel bzip2 bzip2-devel libjpeg-devel rpm-devel rpm-build redhat-rpm-config

# Define environment variable. This is needed by the Makefile
ENV prefix /root/install
ENV PATH $prefix/install/bin:$prefix/install/deps/bin:$PATH
