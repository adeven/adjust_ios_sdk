#!/usr/bin/env bash

# End script if one of the lines fails
set -e

# Go to root folder
cd ..

# Clean the folders
rm -rf Frameworks/Static
rm -rf Frameworks/Dynamic
rm -rf Frameworks/tvOS

# Create needed folders
mkdir -p Frameworks/Static
mkdir -p Frameworks/Dynamic
mkdir -p Frameworks/tvOS

# Build static AdjustSdk.framework
xcodebuild -target AdjustStatic -configuration Release clean build

# Build dynamic AdjustSdk.framework
xcodebuild -target AdjustSdk -configuration Release clean build

# Build tvOS AdjustSdkTV.framework
# Build it for simulator and device
# No clean when building appletvos since it wipes out appletvsimulator from build folder
xcodebuild -configuration Release -target AdjustSdkTv -arch x86_64 -sdk appletvsimulator clean build
xcodebuild -configuration Release -target AdjustSdkTv -arch arm64 -sdk appletvos build

# Copy tvOS framework to destination
cp -R build/Release-appletvos/AdjustSdkTv.framework Frameworks/tvOS

# Create universal tvOS framework
lipo -create -output Frameworks/tvOS/AdjustSdkTv.framework/AdjustSdkTv build/Release-appletvos/AdjustSdkTv.framework/AdjustSdkTv build/Release-appletvsimulator/AdjustSdkTv.framework/AdjustSdkTv

# Build Carthage AdjustSdk.framework
carthage build --no-skip-current

# Copy build Carthage framework to Frameworks folder
cp -R Carthage/Build/iOS/* Frameworks/Dynamic/

# Build static AdjustTestLibrary.framework
cd AdjustTests/AdjustTestLibrary
xcodebuild -target AdjustTestLibraryStatic -configuration Debug clean build
