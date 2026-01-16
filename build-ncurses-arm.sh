#!/bin/bash
set -ex

ANDROID_NDK_HOME="/opt/homebrew/share/android-ndk"
ANDROID_NDK_ROOT="$ANDROID_NDK_HOME"
TOOLCHAIN="$ANDROID_NDK_HOME/toolchains/llvm/prebuilt/darwin-x86_64"
API=24

cd /Users/jyo/projects/ai/mosh-android/src/ncurses-6.4

echo "Using CC: $TOOLCHAIN/bin/armv7a-linux-androideabi${API}-clang"

export CC="$TOOLCHAIN/bin/armv7a-linux-androideabi${API}-clang"
export CXX="$TOOLCHAIN/bin/armv7a-linux-androideabi${API}-clang++"
export AR="$TOOLCHAIN/bin/llvm-ar"
export RANLIB="$TOOLCHAIN/bin/llvm-ranlib"
export STRIP="$TOOLCHAIN/bin/llvm-strip"

./configure \
    --host=arm-linux-androideabi \
    --prefix=/Users/jyo/projects/ai/mosh-android/output/armeabi-v7a/ncurses \
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
    --disable-database \
    --with-fallbacks=xterm,xterm-256color,vt100 \
    ac_cv_header_locale_h=no

make -j$(sysctl -n hw.ncpu)
make install.libs install.includes

# Create symlinks
cd /Users/jyo/projects/ai/mosh-android/output/armeabi-v7a/ncurses/lib
ln -sf libncursesw.a libncurses.a || true
cd /Users/jyo/projects/ai/mosh-android/output/armeabi-v7a/ncurses/include
ln -sf ncursesw ncurses || true

echo "ncurses for armeabi-v7a built!"
