# -- Compile ujprog script

UJPROG=ujprog
GIT_UJPROG=https://github.com/f32c/tools

cd $UPSTREAM_DIR

# -- Clone the sources from github
test -e $UJPROG || git clone --recursive --depth=1 $GIT_UJPROG $UJPROG
git -C $UJPROG pull
echo ""
git -C $UJPROG log -1

# -- Copy the upstream sources into the build directory
rm -rf $BUILD_DIR/$UJPROG
rsync -a $UJPROG $BUILD_DIR --exclude .git

cd $BUILD_DIR/$UJPROG/ujprog

if [ $ARCH == "windows_amd64" ]; then
wget -c https://www.ftdichip.com/Drivers/CDM/CDM%20v2.12.28%20WHQL%20Certified.zip -O ftdi.zip
unzip ftdi.zip amd64/ftd2xx.lib 
fi

if [ $ARCH == "windows_x86" ]; then
wget -c https://www.ftdichip.com/Drivers/CDM/CDM%20v2.12.28%20WHQL%20Certified.zip -O ftdi.zip
unzip ftdi.zip i386/ftd2xx.lib 
fi


sed -i "s/#ifdef __linux__/#ifdef __linux_bad__/g" ujprog.c
sed -i "s/#include <ftd2xx.h>/#include \"ftd2xx.h\"/g" ujprog.c

if [ $ARCH == "darwin" ]; then
    $CROSS /bin/sh -c '${CC} -Wall -o ujprog ujprog.c -I${CROSS_PREFIX}/include/libftdi1 -Bstatic /opt/x86_64-apple-darwin15/lib/libftdi1.a /opt/x86_64-apple-darwin15/lib/libusb-1.0.a -Wl,-framework,IOKit -Wl,-framework,CoreFoundation -lobjc -lpthread'
elif [ $ARCH == "windows_amd64" ]; then
    $CROSS /bin/sh -c '${CC} -o ujprog.exe ujprog.c -s -static -L. -lamd64/ftd2xx'
elif [ $ARCH == "windows_x86" ]; then
    $CROSS /bin/sh -c '${CC} -o ujprog.exe ujprog.c -s -static -L. -li386/ftd2xx'
else
    $CROSS /bin/sh -c '${CC} -Wall -o ujprog ujprog.c -static -lftdi1 -lusb-1.0 -lpthread -L${CROSS_PREFIX}/lib -I${CROSS_PREFIX}/include/libftdi1'
fi

# -- Test the generated executables
test_bin ujprog$EXE

# -- Copy the executable to the bin dir
cp ujprog$EXE $PACKAGE_DIR/$NAME/bin/ujprog$EXE
