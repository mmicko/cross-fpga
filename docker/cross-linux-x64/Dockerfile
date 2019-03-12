FROM mmicko/cross-base:1.0

ENV CROSS_NAME x86_64-linux-gnu

ENV CROSS_PREFIX /opt/${CROSS_NAME}

ENV AS=/usr/bin/${CROSS_NAME}-as \
    AR=/usr/bin/${CROSS_NAME}-ar \
    CC=/usr/bin/${CROSS_NAME}-gcc \
    CPP=/usr/bin/${CROSS_NAME}-cpp \
    CXX=/usr/bin/${CROSS_NAME}-g++ \
    LD=/usr/bin/${CROSS_NAME}-ld

COPY Toolchain.cmake ${CROSS_PREFIX}/

ENV CMAKE_TOOLCHAIN_FILE ${CROSS_PREFIX}/Toolchain.cmake

RUN cd /src/boost && \
    ./bootstrap.sh --prefix=${CROSS_PREFIX} --with-libraries=program_options,filesystem,thread,iostreams && \
    ./b2 link=static install && \
    cd /src/libusb &&  ./configure --prefix=${CROSS_PREFIX} --host=${CROSS_NAME} --enable-udev=no && \
    make -j9 && \
    make install && \
    cd /src/libftdi1 && \
    export PKG_CONFIG_PATH=${CROSS_PREFIX}/lib/pkgconfig && \
    cmake . -DCMAKE_INSTALL_PREFIX=${CROSS_PREFIX} -DBOOST_ROOT=$CROSS_PREFIX && \
    make -j9 && \
    make install && \
    cd /src/libftdi1/examples && \
    ${CC} -o lsftdi find_all.c -static -lftdi1 -lusb-1.0 -lpthread -L${CROSS_PREFIX}/lib -I${CROSS_PREFIX}/include/libftdi1 && \
    cp lsftdi ${CROSS_PREFIX}/bin/. && \
    cd /src/libusb/examples && \
    ${CC} -o lsusb listdevs.c -static -lusb-1.0 -lpthread -L${CROSS_PREFIX}/lib -I${CROSS_PREFIX}/include/libusb-1.0 && \
    cp lsusb ${CROSS_PREFIX}/bin/. && \
    cd / && \
    rm -rf /src 
RUN mkdir /src && \
    cd /src && \
    wget -c https://mirrors.mediatemple.net/debian-archive/debian/pool/main/libu/libusb/libusb_0.1.12.orig.tar.gz && \
    wget -c http://ftp.ubuntu.com/ubuntu/pool/universe/libf/libftdi/libftdi_0.20.orig.tar.gz && \
    tar xvfz libusb_0.1.12.orig.tar.gz && \
    tar xvfz libftdi_0.20.orig.tar.gz && \
    cd /src/libusb-0.1.12 && CFLAGS=-Wno-format-truncation ./configure  --prefix=${CROSS_PREFIX} --enable-udev=no && make install  && \
    cd /src/libftdi-0.20 && export PATH=${CROSS_PREFIX}/bin:$PATH && CFLAGS=-Wno-format-truncation CXXFLAGS="-I${CROSS_PREFIX}/include -L${CROSS_PREFIX}/lib" ./configure --prefix=${CROSS_PREFIX} &&  make install && \
    cd / && \
    rm -rf /src 

