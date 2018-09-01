FROM mmicko/cross-base:1.0

ENV CROSS_NAME arm-linux-gnueabihf

ENV CROSS_PREFIX /opt/${CROSS_NAME}

RUN apt-get -y install gcc-arm-linux-gnueabihf g++-arm-linux-gnueabihf && \
    apt-get clean --yes

ENV AS=/usr/bin/${CROSS_NAME}-as \
    AR=/usr/bin/${CROSS_NAME}-ar \
    CC=/usr/bin/${CROSS_NAME}-gcc \
    CPP=/usr/bin/${CROSS_NAME}-cpp \
    CXX=/usr/bin/${CROSS_NAME}-g++ \
    LD=/usr/bin/${CROSS_NAME}-ld

COPY Toolchain.cmake ${CROSS_PREFIX}/

ENV CMAKE_TOOLCHAIN_FILE ${CROSS_PREFIX}/Toolchain.cmake

RUN cd /src/boost && \
    echo "using gcc : arm : " ${CC} "; " >> tools/build/src/user-config.jam && \
    ./bootstrap.sh --prefix=${CROSS_PREFIX} --with-libraries=program_options,filesystem,thread && \
    ./b2 --toolset=gcc-arm link=static install && \
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
