#!/usr/bin/env bash
# qbuild-wrapper.sh
# Usage: ./qbuild-wrapper.sh foo

PACKAGE="$1"

# Optional USE flags
USE_FLAGS="${USE:-}"
# Optional architectures
ARCHS="${Extaconf:-}"

# default to current arch if none specified
if [ -z "$ARCHS" ]; then
    ARCHS="$(uname -m)"
fi

echo "Building package: $PACKAGE"
echo "USE flags: $USE_FLAGS"
echo "Architectures: $ARCHS"

for arch in $ARCHS; do
    echo "-------------------------------------"
    echo "Building for architecture: $arch"
    
    # Set environment vars
    export CFLAGS="-march=$arch"
    export CXXFLAGS="-march=$arch"
    export USE="$USE_FLAGS"

    # Example emerge/qbuild call
    if command -v emerge >/dev/null 2>&1; then
        echo "Running: emerge --verbose $PACKAGE"
        emerge --verbose "$PACKAGE"
    elif command -v qbuild >/dev/null 2>&1; then
        echo "Running: qbuild $PACKAGE"
        qbuild "$PACKAGE"
    else
        echo "No build system found (emerge/qbuild)"
        exit 1
    fi
done
