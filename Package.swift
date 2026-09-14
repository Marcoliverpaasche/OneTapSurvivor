// swift-tools-version: 5.9
// ─────────────────────────────────────────────
// HINWEIS: Dieses Package.swift ist nur als
// Referenz — in Xcode selbst fügst du das SDK
// über File → Add Package Dependencies hinzu.
// URL: https://github.com/AppLovin/AppLovin-MAX-Swift-Package
// ─────────────────────────────────────────────
import PackageDescription

let package = Package(
    name: "OneTapSurvivor",
    platforms: [.iOS(.v16)],
    dependencies: [
        .package(
            url: "https://github.com/AppLovin/AppLovin-MAX-Swift-Package",
            from: "12.0.0"
        )
    ],
    targets: [
        .target(
            name: "OneTapSurvivor",
            dependencies: [
                .product(name: "AppLovinSDK", package: "AppLovin-MAX-Swift-Package"),
            ]
        )
    ]
)
