// swift-tools-version:5.1
import PackageDescription

var platform: SupportedPlatform {
    #if compiler(<5.3)
        return .iOS(.v8)
    #else
        // Xcode 12 (which ships with Swift 5.3) drops support for iOS 8
        return .iOS(.v9)
    #endif
}

let package = Package(
    name: "TURecipientBar",
    platforms: [
        platform,
    ],
    products: [
        .library(
            name: "TURecipientBar",
            targets: ["TURecipientBar"]
        ),
    ],
    dependencies: [],
    targets: [
        .target(
            name: "TURecipientBar",
            path: "TURecipientBar",
            publicHeadersPath: "."
        ),
    ]
)
