#!/bin/bash
set -e

ANDROID_NDK_HOME="/opt/homebrew/share/android-ndk"
ANDROID_NDK_ROOT="$ANDROID_NDK_HOME"
TOOLCHAIN="$ANDROID_NDK_HOME/toolchains/llvm/prebuilt/darwin-x86_64"
API=24

# Re-extract clean source
cd /Users/jyo/projects/ai/mosh-android/src
rm -rf ncurses-6.4
tar xzf ncurses-6.4.tar.gz
cd ncurses-6.4

export CC="$TOOLCHAIN/bin/x86_64-linux-android${API}-clang"
export CXX="$TOOLCHAIN/bin/x86_64-linux-android${API}-clang++"
export AR="$TOOLCHAIN/bin/llvm-ar"
export RANLIB="$TOOLCHAIN/bin/llvm-ranlib"
export STRIP="$TOOLCHAIN/bin/llvm-strip"

./configure \
    --host=x86_64-linux-android \
    --prefix=/Users/jyo/projects/ai/mosh-android/output/x86_64/ncurses \
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

make -j$(sysctl -n hw.ncpu) || true
make install.libs install.includes

# Create symlinks
cd /Users/jyo/projects/ai/mosh-android/output/x86_64/ncurses/lib
ln -sf libncursesw.a libncurses.a || true
cd /Users/jyo/projects/ai/mosh-android/output/x86_64/ncurses/include
ln -sf ncursesw ncurses || true

echo "ncurses for x86_64 built!"
