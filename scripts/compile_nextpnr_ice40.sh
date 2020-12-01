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

# -- Copy the chipdb*.txt data files
rm -rf BUILD_ICE40
mkdir -p BUILD_ICE40/icebox
cp -r icestorm/icebox/chipdb*.txt BUILD_ICE40/icebox
cp -r icestorm/icefuzz/timings_*.txt BUILD_ICE40/icebox

$CROSS /bin/sh -c 'cd BUILD_ICE40 && cmake ../nextpnr -DARCH=ice40 -DSTATIC_BUILD=ON -DBUILD_PYTHON=OFF -DBUILD_GUI=OFF -DCMAKE_TOOLCHAIN_FILE=$CROSS_PREFIX/Toolchain.cmake -DBOOST_ROOT=$CROSS_PREFIX -DICEBOX_DATADIR=/work/BUILD_ICE40/icebox -DBBA_IMPORT=../BUILD_BBA/bba-export.cmake'

$CROSS make -C BUILD_ICE40 -j$J

# -- Test the generated executables
test_bin BUILD_ICE40/nextpnr-ice40$EXE

# -- Copy the executable to the bin dir
cp BUILD_ICE40/nextpnr-ice40$EXE $PACKAGE_DIR/$NAME/bin/nextpnr-ice40$EXE
