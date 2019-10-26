# -- Compile Iverilog script

IVERILOG=iverilog
GIT_IVERILOG=https://github.com/steveicarus/iverilog

cd $UPSTREAM_DIR

# -- Clone the sources from github
test -e $IVERILOG || git clone $GIT_IVERILOG $IVERILOG
git -C $IVERILOG checkout tags/v10_3
echo ""
git -C $IVERILOG log -1

# -- Copy the upstream sources into the build directory
rsync -a $IVERILOG $BUILD_DIR --exclude .git

cd $BUILD_DIR/$IVERILOG

# -- Generate the new configure
sed -i "s/HOSTCC = @CC@/HOSTCC = gcc/g" Makefile.in
sed -i "s/HOSTCC = @CC@/HOSTCC = gcc/g" vvp/Makefile.in
sed -i "s/\$(CC) \$(CFLAGS) -o draw_tt/gcc \$(CFLAGS) -o draw_tt/g" vvp/Makefile.in
$CROSS /bin/sh autoconf.sh

# -- Force not to use libreadline and libhistory
sed -i "s/ac_cv_lib_readline_readline=yes/ac_cv_lib_readline_readline=no/g" configure
sed -i "s/ac_cv_lib_history_add_history=yes/ac_cv_lib_history_add_history=no/g" configure
sed -i "s/ac_cv_lib_pthread_pthread_create=yes/ac_cv_lib_pthread_pthread_create=no/g" configure

if [ $ARCH == "darwin" ]; then
  sed -i "s/find_ivl_root();/\/\/find_ivl_root();/g" driver/main.c 
fi

# -- Prepare for building
if [ $ARCH == "windows_x86" ] || [ $ARCH == "windows_amd64" ]; then
  $CROSS ./configure --build=x86_64-unknown-linux-gnu HOSTCC=gcc --host=$HOST CFLAGS="-O2" CXXFLAGS="-O2 -Wno-deprecated-declarations" LDFLAGS="-static"
else
  $CROSS ./configure --build=x86_64-unknown-linux-gnu HOSTCC=gcc --host=$HOST CFLAGS="-O2" CXXFLAGS="-O2 -Wno-deprecated-declarations" LDFLAGS="-static-libgcc -static-libstdc++"
fi

# -- Compile it
$CROSS make -j$J

# -- Make binaries static
if [ ${ARCH:0:5} == "linux" ] || [ $ARCH == "darwin" ]; then
  SUBDIRS="driver"
  for SUBDIR in ${SUBDIRS[@]}
  do
    $CROSS make -C $SUBDIR clean
    if [ $ARCH == "darwin" ]; then
      $CROSS make -C $SUBDIR -j$J LDFLAGS="-Bstatic"
    else
      $CROSS make -C $SUBDIR -j$J LDFLAGS="-static"
    fi
  done
fi

# -- Test the generated executables
test_bin driver/iverilog$EXE

if [ $ARCH == "windows" ]; then
  test_bin driver-vpi/iverilog-vpi$EXE
fi

cd $BUILD_DIR/$IVERILOG
rm -rf BUILD_IVERILOG
mkdir -p BUILD_IVERILOG
# -- Install the programs into the package folder
$CROSS make install prefix=/work/BUILD_IVERILOG
mv BUILD_IVERILOG/* $PACKAGE_DIR/$NAME/.
