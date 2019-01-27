# -- Compile nextpnr script

NEXTPNR=nextpnr
GIT_NEXTPNR=https://github.com/YosysHQ/nextpnr

cd $UPSTREAM_DIR

# -- Clone the sources from github
test -e $NEXTPNR || git clone --depth=1 $GIT_NEXTPNR $NEXTPNR
git -C $NEXTPNR pull
echo ""
git -C $NEXTPNR log -1

# -- Copy the upstream sources into the build directory
rsync -a $NEXTPNR $BUILD_DIR #--exclude .git

cd $BUILD_DIR/

$CROSS_HOST /bin/sh -c 'rm -rf BUILD_BBA && mkdir BUILD_BBA && cd BUILD_BBA && cmake ../nextpnr -DARCH=generic -DSTATIC_BUILD=ON -DBUILD_PYTHON=OFF -DBUILD_GUI=OFF -DBOOST_ROOT=$CROSS_PREFIX && make bbasm'

cd $BUILD_DIR

rm -rf BUILD_ECP5
mkdir -p BUILD_ECP5

$CROSS /bin/sh -c 'cd BUILD_ECP5 && cmake ../nextpnr -DARCH=ecp5 -DSTATIC_BUILD=ON -DBUILD_PYTHON=OFF -DBUILD_GUI=OFF -DCMAKE_TOOLCHAIN_FILE=$CROSS_PREFIX/Toolchain.cmake -DBOOST_ROOT=$CROSS_PREFIX -DTRELLIS_ROOT=/work/prjtrellis -DIMPORT_EXECUTABLES=../BUILD_BBA/ImportExecutables.cmake'

$CROSS make -C BUILD_ECP5 -j$J

# -- Test the generated executables
test_bin BUILD_ECP5/nextpnr-ecp5$EXE

# -- Copy the executable to the bin dir
cp BUILD_ECP5/nextpnr-ecp5$EXE $PACKAGE_DIR/$NAME/bin/nextpnr-ecp5$EXE
