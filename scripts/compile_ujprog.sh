# -- Compile ujprog script

UJPROG=ujprog
GIT_UJPROG=https://github.com/f32c/tools

cd $UPSTREAM_DIR

# -- Clone the sources from github
test -e $UJPROG || git clone --recursive --depth=1 $GIT_UJPROG $UJPROG
git -C $UJPROG pull
echo ""
git -C $UJPROG log -1

# -- Copy the upstream sources into the build directory
rm -rf $BUILD_DIR/$UJPROG
rsync -a $UJPROG $BUILD_DIR --exclude .git

cd $BUILD_DIR/$UJPROG/ujprog

sed -i "s/#ifdef __linux__/#ifdef __linux_bad__/g" ujprog.c

$CROSS /bin/sh -c '${CC} -Wall -static -o ujprog ujprog.c -static -lftdi1 -lusb-1.0 -lpthread -L${CROSS_PREFIX}/lib -I${CROSS_PREFIX}/include/libftdi1'

# -- Test the generated executables
test_bin ujprog$EXE

# -- Copy the executable to the bin dir
cp ujprog$EXE $PACKAGE_DIR/$NAME/bin/ujprog$EXE
