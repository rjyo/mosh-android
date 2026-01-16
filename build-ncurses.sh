#!/bin/bash
set -e

export ANDROID_NDK_HOME="/opt/homebrew/share/android-ndk"
export ANDROID_NDK_ROOT="$ANDROID_NDK_HOME"
export TOOLCHAIN=$ANDROID_NDK_HOME/toolchains/llvm/prebuilt/darwin-x86_64
export API=24

BUILD_DIR="/Users/jyo/projects/ai/mosh-android"
SRC_DIR="$BUILD_DIR/src/ncurses-6.4"
OUTPUT_DIR="$BUILD_DIR/output"

build_ncurses() {
    local ARCH=$1
    local TARGET=$2
    local HOST=$3

    echo "=========================================="
    echo "Building ncurses for $ARCH"
    echo "=========================================="

    cd "$SRC_DIR"
    make distclean 2>/dev/null || true

    export CC=$TOOLCHAIN/bin/${TARGET}${API}-clang
    export CXX=$TOOLCHAIN/bin/${TARGET}${API}-clang++
    export AR=$TOOLCHAIN/bin/llvm-ar
    export RANLIB=$TOOLCHAIN/bin/llvm-ranlib
    export STRIP=$TOOLCHAIN/bin/llvm-strip
    export PATH=$TOOLCHAIN/bin:$PATH

    ./configure \
        --host=$HOST \
        --prefix="$OUTPUT_DIR/$ARCH/ncurses" \
        --without-ada \
        --without-cxx \
        --without-cxx-binding \
        --without-manpages \
        --without-progs \
        --without-tests \
        --without-debug \
        --enable-widec \
        --enable-static \
        --disable-shared \
        --with-terminfo-dirs=/system/etc/terminfo:/data/local/tmp/terminfo \
        --with-default-terminfo-dir=/data/local/tmp/terminfo \
        ac_cv_header_locale_h=no

    make -j$(sysctl -n hw.ncpu)

    # Install libraries and headers only (skip terminfo database which fails on cross-compile)
    make install.libs install.includes || true

    # Create symlinks for compatibility
    cd "$OUTPUT_DIR/$ARCH/ncurses/lib"
    ln -sf libncursesw.a libncurses.a 2>/dev/null || true
    ln -sf libformw.a libform.a 2>/dev/null || true
    ln -sf libmenuw.a libmenu.a 2>/dev/null || true
    ln -sf libpanelw.a libpanel.a 2>/dev/null || true

    cd "$OUTPUT_DIR/$ARCH/ncurses/include"
    ln -sf ncursesw ncurses 2>/dev/null || true

    echo "ncurses for $ARCH built successfully!"
}

# Build for arm64-v8a
build_ncurses "arm64-v8a" "aarch64-linux-android" "aarch64-linux-android"

# Build for armeabi-v7a
build_ncurses "armeabi-v7a" "armv7a-linux-androideabi" "arm-linux-androideabi"

# Build for x86_64
build_ncurses "x86_64" "x86_64-linux-android" "x86_64-linux-android"

echo "All ncurses builds complete!"
