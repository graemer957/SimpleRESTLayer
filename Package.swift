// swift-tools-version:4.0

import PackageDescription

let package = Package(
    name: "SimpleRESTLayer",
    products: [
        .library(
            name: "SimpleRESTLayer",
            targets: ["SimpleRESTLayer"])
    ],
    targets: [
        .target(
            name: "SimpleRESTLayer",
            path: "./SimpleRESTLayer")
    ]
)
