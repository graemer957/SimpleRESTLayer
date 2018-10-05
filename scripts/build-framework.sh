################################################################################
#
# build-framework.sh
# Version: 1.0
# Modified: 11.03.2017
#
# Copyright 2017 Graeme Read.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
################################################################################

#
# Original script: http://stackoverflow.com/questions/35586516/is-it-possible-to-create-a-universal-ios-framework-using-bitcode
#
# This script is a modified version of the one posted on StackOverflow
#

######################
# Options
######################
set -x -e
[ -z "$FRAMEWORK_NAME" ] && FRAMEWORK_NAME="${PROJECT_NAME}"
CONFIGURATION=Release
SIMULATOR_LIBRARY_PATH="${BUILD_DIR}/${CONFIGURATION}-iphonesimulator/${FRAMEWORK_NAME}.framework"
DEVICE_LIBRARY_PATH="${BUILD_DIR}/${CONFIGURATION}-iphoneos/${FRAMEWORK_NAME}.framework"
[ -z "$OUTPUT" ] && OUTPUT="${PROJECT_DIR}/release"
[ -z "$FRAMEWORK" ] && FRAMEWORK="${OUTPUT}/${FRAMEWORK_NAME}.framework"


######################
# Cleanup old release
######################
rm -rf "${OUTPUT}"
mkdir "${OUTPUT}"


######################
# Build
######################
# Build for simulator
xcodebuild -target ${PROJECT_NAME} -sdk iphonesimulator -configuration ${CONFIGURATION} -UseModernBuildSystem=NO ARCHS="i386 x86_64" ONLY_ACTIVE_ARCH=NO clean build CONFIGURATION_BUILD_DIR=${BUILD_DIR}/${CONFIGURATION}-iphonesimulator

# Build for device
xcodebuild -scheme ${PROJECT_NAME} -sdk iphoneos -configuration ${CONFIGURATION} -archivePath ${BUILD_DIR} -UseModernBuildSystem=NO ARCHS="armv7 arm64" ONLY_ACTIVE_ARCH=NO clean archive CONFIGURATION_BUILD_DIR=${BUILD_DIR}/${CONFIGURATION}-iphoneos


######################
# Create universal framework
######################
mkdir "${FRAMEWORK}"


######################
# Copy files for framework and debug
######################
cp -r "${DEVICE_LIBRARY_PATH}/." "${FRAMEWORK}"
cp -r "${BUILD_DIR}/${CONFIGURATION}-iphoneos/${FRAMEWORK_NAME}.framework.dSYM" "$OUTPUT"


######################
# Make universal binary
######################
lipo "${SIMULATOR_LIBRARY_PATH}/${FRAMEWORK_NAME}" "${DEVICE_LIBRARY_PATH}/${FRAMEWORK_NAME}" -create -output "${FRAMEWORK}/${FRAMEWORK_NAME}" | echo

# For Swift framework, Swiftmodule needs to be copied in the universal framework
if [ -d "${SIMULATOR_LIBRARY_PATH}/Modules/${FRAMEWORK_NAME}.swiftmodule/" ]; then
cp -fr ${SIMULATOR_LIBRARY_PATH}/Modules/${FRAMEWORK_NAME}.swiftmodule/ "${FRAMEWORK}/Modules/${FRAMEWORK_NAME}.swiftmodule/" | echo
fi

if [ -d "${DEVICE_LIBRARY_PATH}/Modules/${FRAMEWORK_NAME}.swiftmodule/" ]; then
cp -fr ${DEVICE_LIBRARY_PATH}/Modules/${FRAMEWORK_NAME}.swiftmodule/ "${FRAMEWORK}/Modules/${FRAMEWORK_NAME}.swiftmodule/" | echo
fi


######################
# Cleanup build artifacts
######################
rm -rf "${PROJECT_DIR}/build"
