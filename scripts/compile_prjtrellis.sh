# -- Compile prjtrellis script

PRJTRELLIS=prjtrellis
GIT_PRJTRELLIS=https://github.com/SymbiFlow/prjtrellis

cd $UPSTREAM_DIR

# -- Clone the sources from github
test -e $PRJTRELLIS || git clone --depth=1 $GIT_PRJTRELLIS $PRJTRELLIS
git -C $PRJTRELLIS pull
echo ""
git -C $PRJTRELLIS log -1

# -- Copy the upstream sources into the build directory
rsync -a $PRJTRELLIS $BUILD_DIR --exclude .git

cd $BUILD_DIR/$PRJTRELLIS
./download-latest-db.sh
cd $BUILD_DIR

$CROSS_HOST /bin/sh -c 'rm -rf BUILD_PY && mkdir BUILD_PY && cd BUILD_PY && cmake ../prjtrellis/libtrellis'
$CROSS_HOST make -C BUILD_PY pytrellis -j$J

$CROSS /bin/sh -c 'cd prjtrellis/libtrellis && cmake . -DBUILD_PYTHON=OFF -DBUILD_SHARED=OFF -DSTATIC_BUILD=ON -DCMAKE_TOOLCHAIN_FILE=$CROSS_PREFIX/Toolchain.cmake -DBOOST_ROOT=$CROSS_PREFIX'

$CROSS make -C $PRJTRELLIS/libtrellis -j$J

# -- Copy python module to be used by nextpnr
cp BUILD_PY/pytrellis.so $PRJTRELLIS/libtrellis/.

# -- Test the generated executables
test_bin $PRJTRELLIS/libtrellis/ecppack$EXE
test_bin $PRJTRELLIS/libtrellis/ecpunpack$EXE

# -- Copy the executable to the bin dir
cp $PRJTRELLIS/libtrellis/ecppack$EXE $PACKAGE_DIR/$NAME/bin/ecppack$EXE
cp $PRJTRELLIS/libtrellis/ecpunpack$EXE $PACKAGE_DIR/$NAME/bin/ecpunpack$EXE

# -- Copy the chipdb*.bin data files
mkdir -p $PACKAGE_DIR/$NAME/share/trellis
rsync -a $PRJTRELLIS/database $PACKAGE_DIR/$NAME/share/trellis --exclude .git
