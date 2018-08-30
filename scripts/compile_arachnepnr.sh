# -- Compile Arachne PnR script

ARACHNE=arachne-pnr
GIT_ARACHNE=https://github.com/cseed/arachne-pnr.git

cd $UPSTREAM_DIR

# -- Clone the sources from github
test -e $ARACHNE || git clone --depth=1 $GIT_ARACHNE $ARACHNE
git -C $ARACHNE pull
echo ""
git -C $ARACHNE log -1

# -- Copy the upstream sources into the build directory
rsync -a $ARACHNE $BUILD_DIR --exclude .git

cd $BUILD_DIR/

# -- Compile it
if [ $ARCH == "darwin" ]; then
  $CROSS make -C $ARACHNE -j$J LIBS="-lm" ICEBOX="../icestorm/icebox" HOST_CC=gcc HOST_CXX=g++
else
  #sed -i "s/bin\/arachne-pnr\ -d\ /\\/bin\/arachne-pnr\ -d\ /;" $ARACHNE/Makefile
  $CROSS make -C $ARACHNE -j$J LIBS="-static -static-libstdc++ -static-libgcc -lm" ICEBOX="../icestorm/icebox" HOST_CC=gcc HOST_CXX=g++
fi

# -- Test the generated executables
test -e $ARACHNE/share/$ARACHNE/chipdb-1k.bin || exit 1
test -e $ARACHNE/share/$ARACHNE/chipdb-5k.bin || exit 1
test -e $ARACHNE/share/$ARACHNE/chipdb-8k.bin || exit 1
test -e $ARACHNE/share/$ARACHNE/chipdb-384.bin || exit 1
test_bin $ARACHNE/bin/arachne-pnr

# -- Copy the executable to the bin dir
cp $ARACHNE/bin/arachne-pnr $PACKAGE_DIR/$NAME/bin/arachne-pnr$EXE

# -- Copy the chipdb*.bin data files
mkdir -p $PACKAGE_DIR/$NAME/share/$ARACHNE
cp -r $ARACHNE/share/$ARACHNE/chipdb*.bin $PACKAGE_DIR/$NAME/share/$ARACHNE
