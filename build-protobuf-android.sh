#!/bin/bash
set -e

ANDROID_NDK_HOME="/opt/homebrew/share/android-ndk"
BUILD_DIR="/Users/jyo/projects/ai/mosh-android"
SRC_DIR="$BUILD_DIR/src/protobuf-33.3"
OUTPUT_DIR="$BUILD_DIR/output"
API=24

# Ensure we have cmake
which cmake || brew install cmake

build_protobuf() {
    local ARCH=$1
    local ABI=$2

    echo "=========================================="
    echo "Building protobuf for $ARCH"
    echo "=========================================="

    local BUILD="$BUILD_DIR/build/protobuf-$ARCH"
    local OUT="$OUTPUT_DIR/$ARCH/protobuf"

    rm -rf "$BUILD"
    mkdir -p "$BUILD" "$OUT"

    cd "$BUILD"

    cmake "$SRC_DIR" \
        -DCMAKE_TOOLCHAIN_FILE="$ANDROID_NDK_HOME/build/cmake/android.toolchain.cmake" \
        -DANDROID_ABI="$ABI" \
        -DANDROID_PLATFORM="android-$API" \
        -DCMAKE_INSTALL_PREFIX="$OUT" \
        -Dprotobuf_BUILD_TESTS=OFF \
        -Dprotobuf_BUILD_PROTOC_BINARIES=OFF \
        -Dprotobuf_BUILD_SHARED_LIBS=OFF \
        -Dprotobuf_BUILD_LIBPROTOC=OFF \
        -Dprotobuf_WITH_ZLIB=OFF \
        -Dprotobuf_ABSL_PROVIDER="module" \
        -DCMAKE_BUILD_TYPE=Release

    cmake --build . --parallel $(sysctl -n hw.ncpu)
    cmake --install .

    echo "protobuf for $ARCH built!"
}

# Build for arm64-v8a
build_protobuf "arm64-v8a" "arm64-v8a"

# Build for armeabi-v7a
build_protobuf "armeabi-v7a" "armeabi-v7a"

# Build for x86_64
build_protobuf "x86_64" "x86_64"

echo "All protobuf builds complete!"
