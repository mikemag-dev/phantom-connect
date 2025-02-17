// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "PhantomConnect",
    platforms: [.iOS(.v17)],
    products: [
        .library(
            name: "PhantomConnect",
            targets: ["PhantomConnect"]
        ),
    ],
    dependencies: [
        .package(
            url: "https://github.com/mikemag-dev/Solana.Swift",
            branch: "master"
        )
    ],
    targets: [
        .target(
            name: "PhantomConnect",
            dependencies: [
                .product(
                    name: "Solana",
                    package: "Solana.Swift"
                )
            ],
            exclude: ["PhantomConnectExample", "Assets"]
        ),
        .testTarget(
            name: "PhantomConnectTests",
            dependencies: [
                "PhantomConnect"
            ],
            exclude: ["PhantomConnectExample", "Assets"]
        ),
    ]
)
