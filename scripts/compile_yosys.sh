# -- Compile Yosys script

YOSYS=yosys
GIT_YOSYS=https://github.com/cliffordwolf/yosys.git

cd $UPSTREAM_DIR
# -- Clone the sources from github
test -e $YOSYS || git clone --depth=1 $GIT_YOSYS $YOSYS
git -C $YOSYS pull

# -- Copy the upstream sources into the build directory
rsync -a $YOSYS $BUILD_DIR --exclude .git

cd $BUILD_DIR/$YOSYS

$CROSS make config-gcc-static
if [ $ARCH == "windows_x86" ] || [ $ARCH == "windows_amd64" ]; then
  $CROSS make NO_FPIC=1 ARCHFLAGS="-DWIN32_NO_DLL -DHAVE_STRUCT_TIMESPEC -fpermissive -w -UABC_USE_STDINT_H -DPTW32_STATIC_LIB" -j$J
else
  $CROSS make -j$J
fi

if [ $ARCH != "darwin" ]; then
  # -- Test the generated executables
  test_bin yosys
  test_bin yosys-abc
fi

# -- Copy the executable file
cp yosys $PACKAGE_DIR/$NAME/bin/yosys$EXE
cp yosys-abc $PACKAGE_DIR/$NAME/bin/yosys-abc$EXE

# -- Copy the share folder to the package folder
mkdir -p $PACKAGE_DIR/$NAME/share/yosys
cp -r share/* $PACKAGE_DIR/$NAME/share/yosys
