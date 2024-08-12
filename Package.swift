// swift-tools-version: 5.9

import PackageDescription

let package = Package(
    name: "MeshGradient",
	platforms: [
        .iOS(.v16),
        .macOS(.v13),
        .macCatalyst(.v13),
		.tvOS(.v16),
        .visionOS(.v1),
	],
    products: [
        .library(
            name: "MeshGradient",
            targets: ["MeshGradient"]),
		.library(
            name: "MeshGradientCHeaders",
            targets: ["MeshGradientCHeaders"]),
    ],
    dependencies: [
        .package(url: "https://github.com/quentinfasquel/MeshGradientCodable.git", branch: "main")
    ],
    targets: [
        .target(
            name: "MeshGradient",
            dependencies: [
                "MeshGradientCHeaders",
                "MeshGradientCodable"
            ],
			resources: [.copy("DummyResources/")]
		),
		.target(name: "MeshGradientCHeaders"),
    ]
)
