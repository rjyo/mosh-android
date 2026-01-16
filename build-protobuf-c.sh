#!/bin/bash
set -e

export ANDROID_NDK_HOME="/opt/homebrew/share/android-ndk"
export ANDROID_NDK_ROOT="$ANDROID_NDK_HOME"
export TOOLCHAIN=$ANDROID_NDK_HOME/toolchains/llvm/prebuilt/darwin-x86_64
export API=24

BUILD_DIR="/Users/jyo/projects/ai/mosh-android"
SRC_DIR="$BUILD_DIR/src/protobuf-c/protobuf-c"
OUTPUT_DIR="$BUILD_DIR/output"

build_protobuf_c() {
    local ARCH=$1
    local TARGET=$2

    echo "=========================================="
    echo "Building protobuf-c for $ARCH"
    echo "=========================================="

    local OUT="$OUTPUT_DIR/$ARCH/protobuf-c"
    mkdir -p "$OUT/lib" "$OUT/include"

    export CC=$TOOLCHAIN/bin/${TARGET}${API}-clang
    export AR=$TOOLCHAIN/bin/llvm-ar
    export RANLIB=$TOOLCHAIN/bin/llvm-ranlib

    # Compile the protobuf-c runtime library
    $CC -c -O2 -fPIC -I"$SRC_DIR" "$SRC_DIR/protobuf-c.c" -o /tmp/protobuf-c.o

    # Create static library
    $AR rcs "$OUT/lib/libprotobuf-c.a" /tmp/protobuf-c.o
    $RANLIB "$OUT/lib/libprotobuf-c.a"

    # Copy header
    cp "$SRC_DIR/protobuf-c.h" "$OUT/include/"

    echo "protobuf-c for $ARCH built successfully!"
}

# Build for arm64-v8a
build_protobuf_c "arm64-v8a" "aarch64-linux-android"

# Build for armeabi-v7a
build_protobuf_c "armeabi-v7a" "armv7a-linux-androideabi"

# Build for x86_64
build_protobuf_c "x86_64" "x86_64-linux-android"

echo "All protobuf-c builds complete!"
