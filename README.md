# SimpleRESTLayer
[![Build Status](https://img.shields.io/travis/graemer957/SimpleRESTLayer/master.svg?style=flat-square)](https://travis-ci.org/graemer957/SimpleRESTLayer)
[![codebeat badge](https://codebeat.co/badges/118122e9-f912-47e5-89d2-13a5dcc92f34)](https://codebeat.co/projects/github-com-graemer957-simplerestlayer-master)
[![Language](https://img.shields.io/badge/language-Swift%203.0-orange.svg?style=flat-square)](https://developer.apple.com/swift/)
[![Platforms](https://img.shields.io/badge/platform-ios-yellow.svg?style=flat-square)](http://www.apple.com/ios/)
[![License](https://img.shields.io/badge/license-Apache--2.0-lightgrey.svg?style=flat-square)](https://github.com/graemer957/helloworld-swift-framework/blob/master/LICENSE)

A simple REST layer built on top of NSURLSession

# Build environment
- Xcode 8.2.1
- Swift 3.0.2
- macOS 10.12.3

# Dependancies
- None

# Usage
- To be completed

# Resources
- To be completed

# Notes
- When built the framework only builds for armv7 and arm64 (`ARCHS_STANDARD`)

# TODO
- [ ] Add support for fastlane
- [ ] Update demo app to reflect feastures in v0.2
- [ ] Update documentation to reflect feastures in v0.2
- [ ] Add unit tests
- [ ] Add SwiftLint
- [ ] Add support for Carthage
- [ ] Add support for CocoaPods
- [ ] Add support for codecov.io (or similar)
- [x] Add codebeat.co

# Current Limitations
- POSTing is always performed using form URL encoding
- `RESTClient` assumes that all responses are JSON
