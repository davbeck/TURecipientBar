// swift-tools-version:5.3
import PackageDescription

let package = Package(
    name: "TURecipientBar",
    platforms: [
        .iOS(.v9),
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
