FROM ubuntu:trusty

WORKDIR /root

RUN apt-get -y update
RUN apt-get -y install libcurl4-openssl-dev make cmake g++ gcc libcppunit-dev libbz2-dev libssl-dev uuid-dev libtool
RUN apt-get -y install flex bison autoconf automake libreadline-dev libicu-dev libxml2-dev libjpeg-dev bzip2
RUN apt-get -y install git curl xz-utils debhelper devscripts

ENV HOME /root
ENV prefix $HOME/install
ENV PATH $prefix/bin:$prefix/deps/bin:$PATH
