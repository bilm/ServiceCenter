// swift-tools-version:5.5
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "ServiceCenter",
	platforms: [ .macOS(.v11), .iOS(.v15) ],
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .library(
            name: "ServiceCenter",
            targets: ["ServiceCenter"]),
    ],
    dependencies: [

		.package(url: "git@github.com:bilm/DateFormats.git", .branch("swift-5_3")),
		.package(url: "git@github.com:bilm/Logger.git", .branch("swift-5_3")),
		.package(url: "git@github.com:bilm/Metadata.git", .branch("swift-5_3")),

    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .target(
            name: "ServiceCenter",
            dependencies: [
				
				.product(name: "Logger", package: "Logger"),
				.product(name: "DateFormats", package: "DateFormats"),
				.product(name: "Metadata", package: "Metadata"),
				
			]),
        .testTarget(
            name: "ServiceCenterTests",
            dependencies: ["ServiceCenter"]),
    ]
)