#!/bin/bash
set -e

ANDROID_NDK_HOME="/opt/homebrew/share/android-ndk"
TOOLCHAIN="$ANDROID_NDK_HOME/toolchains/llvm/prebuilt/darwin-x86_64"
SYSROOT="$TOOLCHAIN/sysroot"
API=24

BUILD_DIR="/Users/jyo/projects/ai/mosh-android"
MOSH_SRC="$BUILD_DIR/src/mosh"
OUTPUT_DIR="$BUILD_DIR/output"

build_mosh() {
    local ARCH=$1
    local TARGET=$2
    local HOST=$3

    echo "=========================================="
    echo "Building mosh for $ARCH"
    echo "=========================================="

    cd "$MOSH_SRC"
    make distclean 2>/dev/null || true

    local OUT="$OUTPUT_DIR/$ARCH"

    export CC="$TOOLCHAIN/bin/${TARGET}${API}-clang"
    export CXX="$TOOLCHAIN/bin/${TARGET}${API}-clang++"
    export AR="$TOOLCHAIN/bin/llvm-ar"
    export RANLIB="$TOOLCHAIN/bin/llvm-ranlib"
    export STRIP="$TOOLCHAIN/bin/llvm-strip"

    # Set up include and library paths
    local PROTOBUF_DIR="$OUT/protobuf"
    local OPENSSL_DIR="$OUT/openssl"
    local NCURSES_DIR="$OUT/ncurses"

    export CPPFLAGS="-I$PROTOBUF_DIR/include -I$OPENSSL_DIR/include -I$NCURSES_DIR/include -I$NCURSES_DIR/include/ncursesw -I$MOSH_SRC -I$MOSH_SRC/src/protobufs"
    export LDFLAGS="-L$PROTOBUF_DIR/lib -L$OPENSSL_DIR/lib -L$NCURSES_DIR/lib"

    # Need to link all the abseil libraries protobuf depends on
    ABSL_LIBS=""
    for lib in $PROTOBUF_DIR/lib/libabsl_*.a; do
        ABSL_LIBS="$ABSL_LIBS $lib"
    done

    export LIBS="-lprotobuf $ABSL_LIBS -lssl -lcrypto -lncursesw -llog -lz"

    # Set pkg-config paths
    export PKG_CONFIG_PATH="$PROTOBUF_DIR/lib/pkgconfig:$OPENSSL_DIR/lib/pkgconfig:$NCURSES_DIR/lib/pkgconfig"
    export PKG_CONFIG_LIBDIR="$PKG_CONFIG_PATH"

    # Configure mosh
    ./configure \
        --host=$HOST \
        --prefix="$OUT/mosh" \
        --with-crypto-library=openssl \
        --disable-client \
        --disable-server \
        --enable-static \
        --disable-shared \
        --with-ncurses \
        PROTOC=/opt/homebrew/bin/protoc \
        protobuf_CFLAGS="-I$PROTOBUF_DIR/include" \
        protobuf_LIBS="-L$PROTOBUF_DIR/lib -lprotobuf" \
        OpenSSL_CFLAGS="-I$OPENSSL_DIR/include" \
        OpenSSL_LIBS="-L$OPENSSL_DIR/lib -lssl -lcrypto" \
        TINFO_CFLAGS="-I$NCURSES_DIR/include/ncursesw" \
        TINFO_LIBS="-L$NCURSES_DIR/lib -lncursesw"

    # Build only the libraries we need
    make -j$(sysctl -n hw.ncpu)

    # Copy built libraries to output
    mkdir -p "$OUT/mosh/lib" "$OUT/mosh/include"
    cp src/crypto/libmoshcrypto.a "$OUT/mosh/lib/"
    cp src/network/libmoshnetwork.a "$OUT/mosh/lib/"
    cp src/protobufs/libmoshprotos.a "$OUT/mosh/lib/"
    cp src/statesync/libmoshstatesync.a "$OUT/mosh/lib/"
    cp src/terminal/libmoshterminal.a "$OUT/mosh/lib/"
    cp src/util/libmoshutil.a "$OUT/mosh/lib/"

    # Copy headers
    cp -r src/include/* "$OUT/mosh/include/" 2>/dev/null || true
    cp -r src/crypto/*.h "$OUT/mosh/include/" 2>/dev/null || true
    cp -r src/network/*.h "$OUT/mosh/include/" 2>/dev/null || true
    cp -r src/statesync/*.h "$OUT/mosh/include/" 2>/dev/null || true
    cp -r src/terminal/*.h "$OUT/mosh/include/" 2>/dev/null || true
    cp -r src/util/*.h "$OUT/mosh/include/" 2>/dev/null || true
    cp -r src/protobufs/*.pb.h "$OUT/mosh/include/" 2>/dev/null || true

    echo "mosh for $ARCH built!"
}

# Build for arm64-v8a
build_mosh "arm64-v8a" "aarch64-linux-android" "aarch64-linux-android"

# Build for armeabi-v7a
build_mosh "armeabi-v7a" "armv7a-linux-androideabi" "arm-linux-androideabi"

# Build for x86_64
build_mosh "x86_64" "x86_64-linux-android" "x86_64-linux-android"

echo "mosh build complete for all architectures!"
