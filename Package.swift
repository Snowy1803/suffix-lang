// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "SuffixLang",
    platforms: [.macOS("10.15.4")],
    products: [
        .library(
            name: "SuffixLang",
            targets: ["SuffixLang"]),
        .executable(
            name: "suffix",
            targets: ["Driver"]),
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-argument-parser", from: "1.0.0"),
        .package(url: "https://github.com/onevcat/Rainbow", from: "4.0.1"),
        .package(url: "https://github.com/apple/sourcekit-lsp", branch: "main"),
    ],
    targets: [
        .target(
            name: "SuffixLang",
            dependencies: []),
        .target(
            name: "Sema",
            dependencies: ["SuffixLang"]),
        
        .executableTarget(
            name: "Driver",
            dependencies: [
                "SuffixLang",
                "Sema",
                .product(name: "ArgumentParser", package: "swift-argument-parser"),
                .product(name: "Rainbow", package: "Rainbow"),
            ]),
        .executableTarget(
            name: "LSP",
            dependencies: [
                "SuffixLang",
                "Sema",
                .product(name: "ArgumentParser", package: "swift-argument-parser"),
                .product(name: "LSPBindings", package: "sourcekit-lsp"),
            ]),
        
        .testTarget(
            name: "SuffixLangTests",
            dependencies: ["SuffixLang", "Sema"]),
    ]
)
