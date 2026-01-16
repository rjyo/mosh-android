# Mosh for Android

Pre-built static libraries for [mosh (mobile shell)](https://mosh.org/) and all its dependencies, ready for Android NDK integration.

## Supported Architectures

| Architecture | Description |
|-------------|-------------|
| `arm64-v8a` | 64-bit ARM (most modern Android devices) |
| `armeabi-v7a` | 32-bit ARM (older devices) |
| `x86_64` | 64-bit x86 (emulators, some tablets) |

## Libraries Included

### Mosh (v1.4.0)
- `libmoshcrypto.a` - Cryptographic functions (OCB mode)
- `libmoshnetwork.a` - UDP transport layer
- `libmoshprotos.a` - Protocol buffer definitions
- `libmoshstatesync.a` - State synchronization protocol
- `libmoshterminal.a` - Terminal emulation
- `libmoshutil.a` - Utility functions

### Dependencies
- **OpenSSL 3.2.1** - `libssl.a`, `libcrypto.a`
- **Protocol Buffers 33.3** - `libprotobuf.a` + abseil-cpp libraries
- **ncurses 6.4** - `libncursesw.a`

## Directory Structure

```
mosh-android/
├── android-libs/           # Packaged libraries ready for use
│   ├── include/            # Header files
│   ├── static/             # Static libraries per architecture
│   │   ├── arm64-v8a/
│   │   ├── armeabi-v7a/
│   │   └── x86_64/
│   └── README.md           # CMake integration guide
├── build-*.sh              # Build scripts (for rebuilding)
└── README.md               # This file
```

## Usage

### CMake Integration

```cmake
set(MOSH_LIBS_DIR ${CMAKE_SOURCE_DIR}/path/to/android-libs)

include_directories(${MOSH_LIBS_DIR}/include)

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

### React Native / Expo

For React Native integration, you'll need to create a native module that wraps the mosh libraries. See the iOS implementation in [MoshClient](../MoshClient) for reference.

## Building from Source

If you need to rebuild the libraries:

```bash
# Prerequisites
brew install android-ndk autoconf automake protobuf

# Build everything
./build-openssl.sh
./build-protobuf-android.sh
./build-ncurses-arm.sh
./build-ncurses-x86_64.sh
./build-mosh.sh
./package-android.sh
```

### Build Requirements
- macOS with Homebrew
- Android NDK r29+
- autoconf, automake
- protoc (matching version for cross-compile)

## Patches Applied

The following patches were applied during the build:

1. **locale_utils.cc** - Added Android fallback for `nl_langinfo()` since Android's Bionic libc doesn't support it. Returns UTF-8 by default on Android.

## License

- Mosh is licensed under GPLv3
- OpenSSL is dual-licensed under Apache 2.0 and OpenSSL License
- Protocol Buffers is licensed under BSD-3-Clause
- ncurses is licensed under MIT

## Related Projects

- [mosh](https://github.com/mobile-shell/mosh) - Original mosh project
- [Termux](https://github.com/termux/termux-packages) - Reference for Android builds
