# -- Compile Iverilog script

IVERILOG=iverilog
GIT_IVERILOG=https://github.com/steveicarus/iverilog

cd $UPSTREAM_DIR

# -- Clone the sources from github
test -e $IVERILOG || git clone --depth=1 $GIT_IVERILOG $IVERILOG
git -C $IVERILOG pull
echo ""
git -C $IVERILOG log -1

# -- Copy the upstream sources into the build directory
rsync -a $IVERILOG $BUILD_DIR --exclude .git

cd $BUILD_DIR/$IVERILOG

# -- Generate the new configure
sed -i "s/HOSTCC = @CC@/HOSTCC = gcc/g" Makefile.in
sed -i "s/HOSTCC = @CC@/HOSTCC = gcc/g" vvp/Makefile.in
$CROSS /bin/sh autoconf.sh

# -- Prepare for building
$CROSS ./configure --build=x86_64-unknown-linux-gnu HOSTCC=gcc --host=$HOST CFLAGS="-O2" CXXFLAGS="-O2 -Wno-deprecated-declarations" LDFLAGS="-static-libgcc -static-libstdc++"

# -- Compile it
$CROSS make -j$J

# -- Make binaries static
if [ ${ARCH:0:5} == "linux" ]; then
  SUBDIRS="driver vvp"
  for SUBDIR in ${SUBDIRS[@]}
  do
    $CROSS make -C $SUBDIR clean
    $CROSS make -C $SUBDIR -j$J LDFLAGS="-static"
  done
fi

# -- Test the generated executables
test_bin driver/iverilog$EXE
test_bin vvp/vvp$EXE

if [ $ARCH == "linux" ]; then
  test_bin iverilog-vpi
fi

if [ $ARCH == "windows" ]; then
  test_bin driver-vpi/iverilog-vpi$EXE
fi

#cd $BUILD_DIR

#rm -rf BUILD_IVERILOG
#mkdir -p BUILD_IVERILOG
# -- Install the programs into the package folder
#$CROSS make -C $IVERILOG install prefix=../BUILD_IVERILOG
#mv BUILD_IVERILOG/* $PACKAGE_DIR/$NAME/.