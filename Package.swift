// swift-tools-version: 5.8
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "TargetsSDK",
    platforms: [
        .iOS(.v15)
    ],
    products: [
        .library(
            name: "TargetsSDK",
            targets: ["TargetsSDK"]),
    ],
    targets: [
        .binaryTarget(
            name: "TargetsSDK",
            url: "https://karmakod.ru/TargetsSDK.xcframework.zip",
            checksum: "2ab6e6ac18b129a47f0501d0c8e52553ee227b5c893179fe79391d5643186b70"
        )
    ]
)
