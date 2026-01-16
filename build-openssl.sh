#!/bin/bash
set -e

export ANDROID_NDK_HOME="/opt/homebrew/share/android-ndk"
export ANDROID_NDK_ROOT="$ANDROID_NDK_HOME"
export TOOLCHAIN=$ANDROID_NDK_HOME/toolchains/llvm/prebuilt/darwin-x86_64
export API=24

BUILD_DIR="/Users/jyo/projects/ai/mosh-android"
SRC_DIR="$BUILD_DIR/src/openssl-3.2.1"
OUTPUT_DIR="$BUILD_DIR/output"

build_openssl() {
    local ARCH=$1
    local TARGET=$2
    local OPENSSL_ARCH=$3

    echo "=========================================="
    echo "Building OpenSSL for $ARCH"
    echo "=========================================="

    cd "$SRC_DIR"
    make clean 2>/dev/null || true

    export AR=$TOOLCHAIN/bin/llvm-ar
    export CC=$TOOLCHAIN/bin/${TARGET}${API}-clang
    export AS=$CC
    export CXX=$TOOLCHAIN/bin/${TARGET}${API}-clang++
    export LD=$TOOLCHAIN/bin/ld
    export RANLIB=$TOOLCHAIN/bin/llvm-ranlib
    export STRIP=$TOOLCHAIN/bin/llvm-strip
    export PATH=$TOOLCHAIN/bin:$PATH

    ./Configure $OPENSSL_ARCH \
        -D__ANDROID_API__=$API \
        --prefix="$OUTPUT_DIR/$ARCH/openssl" \
        no-shared \
        no-tests

    make -j$(sysctl -n hw.ncpu)
    make install_sw

    echo "OpenSSL for $ARCH built successfully!"
}

# Build for arm64-v8a
build_openssl "arm64-v8a" "aarch64-linux-android" "android-arm64"

# Build for armeabi-v7a
build_openssl "armeabi-v7a" "armv7a-linux-androideabi" "android-arm"

# Build for x86_64
build_openssl "x86_64" "x86_64-linux-android" "android-x86_64"

echo "All OpenSSL builds complete!"
