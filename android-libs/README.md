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
