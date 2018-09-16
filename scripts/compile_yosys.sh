# -- Compile Yosys script

YOSYS=yosys
GIT_YOSYS=https://github.com/YosysHQ/yosys

cd $UPSTREAM_DIR
# -- Clone the sources from github
test -e $YOSYS || git clone --depth=1 $GIT_YOSYS $YOSYS
git -C $YOSYS pull
echo ""
git -C $YOSYS log -1

# -- Copy the upstream sources into the build directory
rsync -a $YOSYS $BUILD_DIR --exclude .git

cd $BUILD_DIR/$YOSYS

$CROSS make config-gcc-static

if [ $ARCH == "darwin" ]; then
  sed -i "s/ -static/ -Bstatic/;" Makefile
fi

if [ $ARCH == "windows_x86" ] || [ $ARCH == "windows_amd64" ]; then
  sed -i "s/CXXFLAGS += -std=c++11 -Os/CXXFLAGS += -std=c++11 -Os -DYOSYS_WIN32_UNIX_DIR /g" Makefile
  $CROSS make ARCHFLAGS="-DWIN32_NO_DLL -DHAVE_STRUCT_TIMESPEC -fpermissive -w -UABC_USE_STDINT_H -DPTW32_STATIC_LIB" -j$J
else
  $CROSS make -j$J
fi

# -- Test the generated executables
test_bin yosys
test_bin yosys-abc

# -- Copy the executable file
cp yosys $PACKAGE_DIR/$NAME/bin/yosys$EXE
cp yosys-abc $PACKAGE_DIR/$NAME/bin/yosys-abc$EXE

# -- Copy the share folder to the package folder
mkdir -p $PACKAGE_DIR/$NAME/share/yosys
cp -r share/* $PACKAGE_DIR/$NAME/share/yosys
