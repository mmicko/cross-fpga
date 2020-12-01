# -- Compile Icestorm script

ICESTORM=icestorm
GIT_ICESTORM=https://github.com/YosysHQ/icestorm.git

cd $UPSTREAM_DIR

# -- Clone the sources from github
test -e $ICESTORM || git clone --depth=1 $GIT_ICESTORM $ICESTORM
git -C $ICESTORM pull
echo ""
git -C $ICESTORM log -1

# -- Copy the upstream sources into the build directory
rsync -a $ICESTORM $BUILD_DIR --exclude .git

cd $BUILD_DIR/$ICESTORM

# -- Compile it
if [ $ARCH == "darwin" ]; then
  sed -i "s/LDLIBS/#LDLIBS/;" iceprog/Makefile
  $CROSS make -j$J SUBDIRS="iceprog" \
            LDFLAGS="-Bstatic -pthread -L$CROSS_PREFIX/lib -Bstatic $CROSS_PREFIX/lib/libftdi1.a $CROSS_PREFIX/lib/libusb-1.0.a -Wl,-framework,IOKit -Wl,-framework,CoreFoundation -lobjc" \
            CFLAGS="-MD -O2 -Wall -std=c99 -I$CROSS_PREFIX/include/libftdi1"
  $CROSS make -j$J SUBDIRS="icebox icepack icemulti icepll icetime icebram" OPT_LEVEL=2 DBG_LEVEL=
else
  $CROSS make -j$J SUBDIRS="iceprog" PKG_CONFIG_PATH=$CROSS_PREFIX/lib/pkgconfig \
            LDFLAGS="-static -pthread -L$CROSS_PREFIX/lib" \
            CFLAGS="-MD -O2 -Wall -std=c99 -I$CROSS_PREFIX/include/libftdi1" 
  $CROSS make -j$J SUBDIRS="icebox icepack icemulti icepll icetime icebram" STATIC=1 OPT_LEVEL=2 DBG_LEVEL=
fi

TOOLS="icepack iceprog icemulti icepll icetime icebram"

# -- Test the generated executables
for dir in $TOOLS; do
    test_bin $dir/$dir
done

# -- Copy the executables to the bin dir
for dir in $TOOLS; do
  cp $dir/$dir $PACKAGE_DIR/$NAME/bin/$dir$EXE
done

# -- Copy the chipdb*.txt data files
mkdir -p $PACKAGE_DIR/$NAME/share/icebox
cp -r icebox/chipdb*.txt $PACKAGE_DIR/$NAME/share/icebox
cp -r icefuzz/timings_*.txt $PACKAGE_DIR/$NAME/share/icebox
