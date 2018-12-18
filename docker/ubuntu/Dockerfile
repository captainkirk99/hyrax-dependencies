FROM ubuntu:trusty

WORKDIR /root

RUN apt-get -y update
RUN apt-get -y install libcurl4-openssl-dev make g++ gcc libcppunit-dev libbz2-dev libssl-dev uuid-dev

ENV HOME /root
ENV prefix $HOME/install
ENV PATH $prefix/bin:$prefix/deps/bin:$PATH