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
            checksum: "8d26f88b90045b9c4a287a57ea8ca00ba413af822bfe808cd2f3e34e0f939a97"
        )
    ]
)
