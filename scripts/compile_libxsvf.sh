# -- Compile ujprog script

LIBXSVF=libxsvf
SVN_LIBXSVF=http://svn.clifford.at/libxsvf/trunk/

cd $UPSTREAM_DIR

# -- Clone the sources from github
test -e $LIBXSVF || svn co $SVN_LIBXSVF $LIBXSVF
svn up $LIBXSVF
echo ""
svn log $LIBXSVF -l 1

# -- Copy the upstream sources into the build directory
rm -rf $BUILD_DIR/$LIBXSVF
rsync -a $LIBXSVF $BUILD_DIR --exclude .svn

cd $BUILD_DIR/$LIBXSVF

if [ $ARCH == "darwin" ]; then
    $CROSS /bin/sh -c '${CC} -o xsvftool-ft232h xsvftool-ft232h.c tap.c statename.c memname.c svf.c xsvf.c scan.c play.c -Wall -Os -ggdb -MD -I${CROSS_PREFIX}/include -Bstatic /opt/x86_64-apple-darwin15/lib/libftdi.a /opt/x86_64-apple-darwin15/lib/libusb.a -Wl,-framework,IOKit -Wl,-framework,CoreFoundation -lobjc -lpthread'
elif [ $ARCH == "windows_amd64" ]; then
    echo "No Win64 support for libxsvf"
elif [ $ARCH == "windows_x86" ]; then
    echo "No Win32 support for libxsvf"
else
    $CROSS /bin/sh -c '${CC} -o xsvftool-ft232h xsvftool-ft232h.c tap.c statename.c memname.c svf.c xsvf.c scan.c play.c -Wall -Os -ggdb -MD -static -lftdi -lusb -lm -lpthread -L${CROSS_PREFIX}/lib -I${CROSS_PREFIX}/include'
fi

if [ $ARCH != "windows_x86" ] && [ $ARCH  != "windows_amd64" ]; then

# -- Test the generated executables
test_bin xsvftool-ft232h$EXE

# -- Copy the executable to the bin dir
cp xsvftool-ft232h$EXE $PACKAGE_DIR/$NAME/bin/xsvftool-ft232h$EXE

fi
