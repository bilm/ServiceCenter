// swift-tools-version:5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "ServiceCenter",
	platforms: [ .macOS(.v12), .iOS(.v15) ],
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .library(
            name: "ServiceCenter",
            targets: ["ServiceCenter"]),
    ],
    dependencies: [

		.package(url: "https://gitlab.com/alitheon/logger.git", branch:"main"),

    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .target(
            name: "ServiceCenter",
            dependencies: [
				
				.product(name: "Logger", package: "Logger"),
				
			]),
        .testTarget(
            name: "ServiceCenterTests",
            dependencies: ["ServiceCenter"]),
    ]
)
