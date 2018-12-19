FROM ubuntu:trusty

WORKDIR /root

RUN apt-get -y update
RUN apt-get -y install libcurl4-openssl-dev make g++ gcc libcppunit-dev libbz2-dev libssl-dev uuid-dev
RUN apt-get -y install bison flex autoconf automake libgdal-dev libreadline-dev libicu-dev libxml2-dev libjpeg-dev
RUN apt-get -y install bzip2 libtool

ENV HOME /root
ENV prefix $HOME/install
ENV PATH $prefix/bin:$prefix/deps/bin:$PATH