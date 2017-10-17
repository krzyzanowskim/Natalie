// swift-tools-version:4.0
import PackageDescription

_ = Package(
    name: "natalie",
    targets: [
        .target(name: "natalie"),
        .testTarget(name: "natalie-tests", path: "natalie-tests")
    ],
    swiftLanguageVersions: [4]
)
