// swift-tools-version:5.1
import PackageDescription

let package = Package(
    name: "TURecipientBar",
    platforms: [
        .iOS(.v8),
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
