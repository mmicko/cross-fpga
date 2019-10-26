# -- Compile Verilator script

VERILATOR=verilator
GIT_VERILATOR=https://github.com/verilator/verilator

cd $UPSTREAM_DIR

# -- Clone the sources from github
test -e $VERILATOR || git clone $GIT_VERILATOR $VERILATOR
git -C $VERILATOR checkout tags/verilator_4_020
echo ""
git -C $VERILATOR log -1

# -- Copy the upstream sources into the build directory
rsync -a $VERILATOR $BUILD_DIR --exclude .git

cd $BUILD_DIR/$VERILATOR

# -- Generate the new configure
$CROSS autoconf -f

# -- Prepare for building
$CROSS ./configure --build=x86_64-unknown-linux-gnu --host=$HOST 

# -- Add missing include needed for windows and darwind builds
cp /usr/include/FlexLexer.h $BUILD_DIR/$VERILATOR/src/.

# -- Compile it
if [ $ARCH == "darwin" ]; then
  $CROSS make opt -C src -j$J CFLAGS="-O2" CXXFLAGS="-O2" LDFLAGS="-Bstatic"
else
  $CROSS make opt -C src -j$J CFLAGS="-O2" CXXFLAGS="-O2" LDFLAGS="-static"
fi

# -- Test the generated executables
test_bin bin/verilator_bin

# -- Copy the executable to the bin dir
cp bin/verilator_bin $PACKAGE_DIR/$NAME/bin/verilator$EXE
