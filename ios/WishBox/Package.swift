// swift-tools-version: 5.9
// Este arquivo ajuda o Xcode a reconhecer a estrutura Swift
// NÃO é necessário para projeto Xcode tradicional, mas ajuda na organização

import PackageDescription

let package = Package(
    name: "WishBox",
    platforms: [
        .iOS(.v16)
    ],
    products: [
        .library(
            name: "WishBox",
            targets: ["WishBox"]
        ),
    ],
    dependencies: [],
    targets: [
        .target(
            name: "WishBox",
            dependencies: [],
            path: "WishBox"
        ),
    ]
)
