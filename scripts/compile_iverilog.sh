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
$CROSS ./configure --build=x86_64-unknown-linux-gnu HOSTCC=gcc --host=$HOST CFLAGS="-O2" CXXFLAGS="-O2 -Wno-deprecated-declarations"

# -- Compile it
$CROSS make -j$J dep config.h _pli_types.h version_tag.h version.exe 

# -- Make binaries static
SUBDIRS="driver vvp"
for SUBDIR in ${SUBDIRS[@]}
do
if [ $ARCH == "darwin" ]; then
  $CROSS make -C $SUBDIR -j$J LDFLAGS="-Bstatic"
else
  $CROSS make -C $SUBDIR -j$J LDFLAGS="-static"
fi
done

# -- Test the generated executables
test_bin driver/iverilog$EXE
test_bin vvp/vvp$EXE

# -- Copy the executable to the bin dir
cp driver/iverilog$EXE $PACKAGE_DIR/$NAME/bin/iverilog$EXE
cp vvp/vvp$EXE $PACKAGE_DIR/$NAME/bin/vvp$EXE