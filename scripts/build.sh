#!/bin/sh

BUILD_PATH=`xcrun swift build -c release --static-swift-stdlib --show-bin-path`
cp "$BUILD_PATH/natalie" .
echo "Binary at path $PWD/natalie"
