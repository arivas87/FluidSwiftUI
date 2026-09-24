// swift-tools-version: 6.4
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "FluidSwiftUI",
    platforms: [.iOS(.v15)],
    products: [
        .library(
            name: "FluidSwiftUI",
            targets: ["FluidSwiftUI"]
        ),
        .library(
            name: "FluidSwiftUIExamples",
            targets: ["FluidSwiftUIExamples"]
        ),
    ],
    targets: [
        .target(
            name: "FluidSwiftUI",
        ),
        .target(
            name: "FluidSwiftUIExamples",
            dependencies: ["FluidSwiftUI"],
            path: "Example"
        ),
        .testTarget(
            name: "FluidSwiftUITests",
            dependencies: ["FluidSwiftUI"],
        ),
    ]
)
