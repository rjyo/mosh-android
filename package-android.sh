#!/bin/bash
set -e

BUILD_DIR="/Users/jyo/projects/ai/mosh-android"
OUTPUT_DIR="$BUILD_DIR/output"
PACKAGE_DIR="$BUILD_DIR/android-libs"

echo "Packaging Android libraries..."

rm -rf "$PACKAGE_DIR"
mkdir -p "$PACKAGE_DIR"

# Create structure for each ABI
for ARCH in arm64-v8a armeabi-v7a x86_64; do
    echo "Packaging $ARCH..."

    ABI_DIR="$PACKAGE_DIR/jniLibs/$ARCH"
    mkdir -p "$ABI_DIR"

    # Create combined static library for mosh
    # For Android, we typically create a single .so that contains everything

    # For now, let's just copy the static libraries
    STATIC_DIR="$PACKAGE_DIR/static/$ARCH"
    mkdir -p "$STATIC_DIR"

    # Copy mosh libraries
    cp "$OUTPUT_DIR/$ARCH/mosh/lib/"*.a "$STATIC_DIR/" 2>/dev/null || true

    # Copy dependency libraries
    cp "$OUTPUT_DIR/$ARCH/openssl/lib/"*.a "$STATIC_DIR/"
    cp "$OUTPUT_DIR/$ARCH/ncurses/lib/"*.a "$STATIC_DIR/"
    cp "$OUTPUT_DIR/$ARCH/protobuf/lib/"*.a "$STATIC_DIR/"
done

# Copy headers (same for all architectures)
mkdir -p "$PACKAGE_DIR/include"
cp -r "$OUTPUT_DIR/arm64-v8a/mosh/include/"* "$PACKAGE_DIR/include/" 2>/dev/null || true
cp -r "$OUTPUT_DIR/arm64-v8a/openssl/include/"* "$PACKAGE_DIR/include/"
cp -r "$OUTPUT_DIR/arm64-v8a/ncurses/include/"* "$PACKAGE_DIR/include/"
cp -r "$OUTPUT_DIR/arm64-v8a/protobuf/include/"* "$PACKAGE_DIR/include/"

# Create a summary
cat > "$PACKAGE_DIR/README.md" << 'EOF'
# Mosh Android Libraries

This package contains pre-built static libraries for mosh and its dependencies for Android.

## Architectures Supported
- arm64-v8a (64-bit ARM)
- armeabi-v7a (32-bit ARM)
- x86_64 (64-bit x86)

## Libraries Included

### Mosh Libraries
- libmoshcrypto.a - Cryptographic functions
- libmoshnetwork.a - Network transport layer
- libmoshprotos.a - Protocol buffer definitions
- libmoshstatesync.a - State synchronization
- libmoshterminal.a - Terminal emulation
- libmoshutil.a - Utility functions

### Dependencies
- OpenSSL (libssl.a, libcrypto.a)
- ncurses (libncursesw.a)
- Protocol Buffers (libprotobuf.a + abseil libraries)

## Usage in CMakeLists.txt

```cmake
# Set the path to the libraries
set(MOSH_LIBS_DIR ${CMAKE_SOURCE_DIR}/mosh-android-libs)

# Add include directories
include_directories(${MOSH_LIBS_DIR}/include)

# Link libraries
target_link_libraries(your_target
    ${MOSH_LIBS_DIR}/static/${ANDROID_ABI}/libmoshnetwork.a
    ${MOSH_LIBS_DIR}/static/${ANDROID_ABI}/libmoshstatesync.a
    ${MOSH_LIBS_DIR}/static/${ANDROID_ABI}/libmoshterminal.a
    ${MOSH_LIBS_DIR}/static/${ANDROID_ABI}/libmoshcrypto.a
    ${MOSH_LIBS_DIR}/static/${ANDROID_ABI}/libmoshutil.a
    ${MOSH_LIBS_DIR}/static/${ANDROID_ABI}/libmoshprotos.a
    ${MOSH_LIBS_DIR}/static/${ANDROID_ABI}/libprotobuf.a
    ${MOSH_LIBS_DIR}/static/${ANDROID_ABI}/libssl.a
    ${MOSH_LIBS_DIR}/static/${ANDROID_ABI}/libcrypto.a
    ${MOSH_LIBS_DIR}/static/${ANDROID_ABI}/libncursesw.a
    log
    z
)
```

## Build Date
Built on: $(date)
EOF

echo ""
echo "=========================================="
echo "Android libraries packaged successfully!"
echo "=========================================="
echo ""
echo "Output directory: $PACKAGE_DIR"
echo ""
ls -la "$PACKAGE_DIR"
