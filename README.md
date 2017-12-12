# SimpleRESTLayer [![pipeline status](https://gitlab.com/optimisedlabs/simplerestlayer/badges/master/pipeline.svg)](https://gitlab.com/optimisedlabs/simplerestlayer/pipelines)

[![codebeat badge](https://codebeat.co/badges/118122e9-f912-47e5-89d2-13a5dcc92f34)](https://codebeat.co/projects/github-com-graemer957-simplerestlayer-master)
[![Language](https://img.shields.io/badge/language-Swift%204.0-orange.svg)](https://developer.apple.com/swift/)
[![Platforms](https://img.shields.io/badge/platform-ios%20%7C%20macos%20%7C%20tvos%20%7C%20watchos%20%7C%20linux-yellow.svg)](https://gitlab.com/optimisedlabs/simplerestlayer)
[![Swift PM](https://img.shields.io/badge/spm-compatible-brightgreen.svg)](https://swift.org/package-manager)
[![Twitter](https://img.shields.io/badge/contact-@graemer957-blue.svg)](https://twitter.com/graemer957)
[![License](https://img.shields.io/badge/license-Apache--2.0-lightgrey.svg)](https://github.com/graemer957/helloworld-swift-framework/blob/master/LICENSE)

A simple REST layer, written in Swift built on top of URLSession. Thanks to the new JSON Encoder/Decoder and Codable in Swift 4 is extremely lightweight and easy to use.

## Features
- [x] Supports [Codable](https://github.com/apple/swift-evolution/blob/master/proposals/0166-swift-archival-serialization.md) models
- [x] JSON / URL Encoding
- [x] Custom HTTP Headers
- [x] Complete working example

## Usage

SimpleRESTLayer should be simple to use and have a self explanatory API.

```swift
struct IP: Codable {
    let address: String
    
    enum CodingKeys: String, CodingKey {
        case address = "origin"
    }
}

import SimpleRESTLayer
let client = RESTClient()

let request = Request.with(method: .get, address: "https://httpbin.org/ip")
client.execute(request: request) { (response: Response<IP>) in
    switch response {
    case let .success(response):
        print("Your IP address is : \(response.model.address)")
        
    case let .failure(error):
        print("Error: \(error)")
    }
}
```

## Dependancies
- [Foundation](https://developer.apple.com/documentation/foundation/urlsession)
- [Dispatch](https://developer.apple.com/documentation/dispatch)

## Requirements
- Swift 4.0+ / Xcode 9.0+
- iOS 10.0+ / macOS 10.12+ / tvOS 10.0+ / watchOS 3.0+
- Ubuntu 14.04 / Ubuntu 16.04 / Ubuntu 16.10

## Installation

### Swift Package Manager

In your `Packages.swift` add:

```swift
.package(url: "https://gitlab.com/optimisedlabs/simplerestlayer.git", .from: "0.5.0")
```

*NOTE*: `.upToNextMinor(from: "0.5.0")` might be better whilst the API stablises.

### Dynamic Framework

Download release zip and add to your Xcode project as an embedded framework. The framework contains slices for armv7 and arm64 (see `ARCHS_STANDARD`). These are always built using the latest version of Xcode / Swift and macOS.

### Manually

Copy the Swift files from `SimpleRESTLayer` into your project.

## TODO
- [x] Add support for fastlane
- [ ] Add unit tests with codecov.io (or similar)
- [x] Add SwiftLint
- [ ] Add support for Carthage
- [ ] Add support for CocoaPods
- [x] Add codebeat.co
- [x] Add support for Swift Package Manager

## Acknowledgements and thanks

The ideas and inspiration for this framework have been sourced from a number of different sources over the years. Whilst this is by no means an exhaustive list, I would like to thank:
- [Apple](https://developer.apple.com), standing on the shoulders of giants...
- [Cocoa with Love](https://www.cocoawithlove.com/blog) blog for various great articles and ideas over the years, not least of all the `Result` type
- [codebeat](https://codebeat.co) for plenty of suggestions on where to focus to improve code quality
- More to come...

## License

SimpleRESTLayer is released under the Apache 2.0 license. See [LICENSE](https://github.com/graemer957/helloworld-swift-framework/blob/master/LICENSE) for details.