FROM ubuntu:bionic

RUN apt-get -qq update \
    && apt-get -y install bison flex gawk git pkg-config python python3 cmake \
                wget python3-dev libboost-all-dev gperf autoconf

RUN mkdir /src && cd /src && wget https://github.com/libusb/libusb/releases/download/v1.0.22/libusb-1.0.22.tar.bz2 && \
    tar xvfj libusb-1.0.22.tar.bz2 && mv libusb-1.0.22 libusb && \
    wget https://www.intra2net.com/en/developer/libftdi/download/libftdi1-1.4.tar.bz2 && \
    tar xvfj libftdi1-1.4.tar.bz2 && mv libftdi1-1.4 libftdi1 && \
    wget https://dl.bintray.com/boostorg/release/1.65.1/source/boost_1_65_1.tar.gz && \
    tar xvfz boost_1_65_1.tar.gz && mv boost_1_65_1 boost

WORKDIR /work