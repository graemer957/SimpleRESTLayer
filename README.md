# SimpleRESTLayer
[![Build Status](https://img.shields.io/travis/graemer957/SimpleRESTLayer/master.svg)](https://travis-ci.org/graemer957/SimpleRESTLayer)
[![codebeat badge](https://codebeat.co/badges/118122e9-f912-47e5-89d2-13a5dcc92f34)](https://codebeat.co/projects/github-com-graemer957-simplerestlayer-master)
[![Language](https://img.shields.io/badge/language-Swift%203.0-orange.svg)](https://developer.apple.com/swift/)
[![Platforms](https://img.shields.io/badge/platform-ios-yellow.svg)](http://www.apple.com/ios/)
[![Swift PM](https://img.shields.io/badge/spm-compatible-brightgreen.svg)](https://swift.org/package-manager)
[![Twitter](https://img.shields.io/badge/contact-@graemer957-blue.svg)](https://twitter.com/graemer957)
[![License](https://img.shields.io/badge/license-Apache--2.0-lightgrey.svg)](https://github.com/graemer957/helloworld-swift-framework/blob/master/LICENSE)

A simple REST layer built on top of URLSession

# Build environment
- Xcode 9.2
- Swift 4.0.3
- macOS 10.13.2

# Dependancies
- None

# Usage
- To be completed

# Resources
- To be completed

# Notes
- When built the framework only builds for armv7 and arm64 (`ARCHS_STANDARD`)

# TODO
- [x] Add support for fastlane
- [ ] Update demo app to reflect feastures in v0.2
- [ ] Update documentation to reflect feastures in v0.2
- [ ] Add unit tests
- [x] Add SwiftLint
- [ ] Add support for Carthage
- [ ] Add support for CocoaPods
- [ ] Add support for codecov.io (or similar)
- [x] Add codebeat.co

# Current Limitations
- POSTing is always performed using form URL encoding
- `RESTClient` assumes that all responses are JSON
