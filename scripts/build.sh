#!/bin/sh

set -e
xcrun swift build -c release --static-swift-stdlib
BUILD_PATH=`xcrun swift build -c release --show-bin-path`
cp "$BUILD_PATH/natalie" .
echo "Binary at path $PWD/natalie"
