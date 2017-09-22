// swift-tools-version:4.0
import PackageDescription

let package = Package(
    name: "SAT",
    products: [
        .library(name: "SAT", targets: ["SAT"]),
    ],
    dependencies: [
    ],
    targets: [
        .target(name: "SAT", dependencies: []),
        .testTarget(name: "SATTests",dependencies: ["SAT"]),
    ])
