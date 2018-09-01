FROM mmicko/cross-base:1.0

ENV CROSS_NAME x86_64-apple-darwin15

ENV CROSS_PREFIX /opt/${CROSS_NAME}

RUN apt-get -y install clang-3.9 llvm-3.9 automake autogen \
                libtool libxml2-dev uuid-dev libssl-dev bash \
                patch make tar xz-utils bzip2 gzip sed cpio curl zlib1g-dev libmpc-dev libmpfr-dev libgmp-dev && \
    apt-get clean --yes && \
    update-alternatives --install /usr/bin/clang clang /usr/bin/clang-3.9 100 \
        --slave /usr/bin/clang++ clang++ /usr/bin/clang++-3.9

ENV MAC_SDK_VERSION 10.11

RUN cd / && curl -L https://github.com/tpoechtrager/osxcross/archive/master.tar.gz | tar xvz && \
    cd /osxcross-master/ && \
    curl -L -o tarballs/MacOSX${MAC_SDK_VERSION}.sdk.tar.xz https://s3.dockerproject.org/darwin/v2/MacOSX10.11.sdk.tar.xz && \
    echo | SDK_VERSION=${MAC_SDK_VERSION} OSX_VERSION_MIN=10.6 ./build.sh && \
    GCC_VERSION=7.3.0 ./build_gcc.sh
    
ENV AS=/osxcross-master/target/bin/${CROSS_NAME}-as \
    AR=/osxcross-master/target/bin/${CROSS_NAME}-ar \
    CC=/osxcross-master/target/bin/${CROSS_NAME}-clang \
    CXX=/osxcross-master/target/bin/${CROSS_NAME}-clang++ \
    LD=/osxcross-master/target/bin/${CROSS_NAME}-ld \ 
    RANLIB=/osxcross-master/target/bin/${CROSS_NAME}-ranlib

ENV PATH /osxcross-master/target/bin:$PATH

COPY Toolchain.cmake ${CROSS_PREFIX}/

ENV CMAKE_TOOLCHAIN_FILE ${CROSS_PREFIX}/Toolchain.cmake

RUN cd /src/boost && \
    echo "using gcc : : " ${CC} "; " >> tools/build/src/user-config.jam && \
    ./bootstrap.sh --prefix=${CROSS_PREFIX} --with-libraries=program_options,filesystem,thread && \
    ./b2 --toolset=gcc --target-os=darwin link=static install && \
    cd /src/libusb &&  ./configure --prefix=${CROSS_PREFIX} --host=${CROSS_NAME} --enable-udev=no && \
    make -j9 && \
    make install && \
    cd /src/libftdi1 && \
    export PKG_CONFIG_PATH=${CROSS_PREFIX}/lib/pkgconfig && \
    cmake . -DCMAKE_INSTALL_PREFIX=${CROSS_PREFIX} -DCMAKE_TOOLCHAIN_FILE=${CROSS_PREFIX}/Toolchain.cmake -DBOOST_ROOT=$CROSS_PREFIX && \
    make -j9 && \
    cmake -DCMAKE_TOOLCHAIN_FILE=${CROSS_PREFIX}/Toolchain.cmake -P cmake_install.cmake  && \
    cd /src/libftdi1/examples && \
    ${CC} -o lsftdi find_all.c -L${CROSS_PREFIX}/lib -I${CROSS_PREFIX}/include/libftdi1 -Bstatic /opt/x86_64-apple-darwin15/lib/libftdi1.a /opt/x86_64-apple-darwin15/lib/libusb-1.0.a -Wl,-framework,IOKit -Wl,-framework,CoreFoundation -lobjc -lpthread  && \
    cp lsftdi ${CROSS_PREFIX}/bin/. && \
    cd /src/libusb/examples && \
    ${CC} -o lsusb listdevs.c -L${CROSS_PREFIX}/lib -I${CROSS_PREFIX}/include/libusb-1.0 -Bstatic /opt/x86_64-apple-darwin15/lib/libusb-1.0.a -Wl,-framework,IOKit -Wl,-framework,CoreFoundation -lobjc -lpthread && \
    cp lsusb ${CROSS_PREFIX}/bin/. && \
    cd / && \
    rm -rf /src 

ENV CC=/osxcross-master/target/bin/${CROSS_NAME}-gcc \
    CXX=/osxcross-master/target/bin/${CROSS_NAME}-g++ \
    OSXCROSS_NO_INCLUDE_PATH_WARNINGS=1
