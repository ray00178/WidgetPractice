// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
  name: "Feature",
  platforms: [.iOS(.v17)],
  products: [
    // Products define the executables and libraries a package produces, making them visible to other packages.
    .library(
      name: "Feature",
      targets: ["Feature"]
    ),
  ],
  dependencies: [
    .package(url: "https://github.com/pointfreeco/swift-composable-architecture", exact: "1.3.0"),
  ],
  targets: [
    // Targets are the basic building blocks of a package, defining a module or a test suite.
    // Targets can depend on other targets in this package and products from dependencies.
    .target(
      name: "Feature",
      dependencies: [.tca]
    ),
    .testTarget(
      name: "FeatureTests",
      dependencies: ["Feature", .tca]
    ),
  ]
)

extension Target.Dependency {
  
  static let tca = Self.product(name: "ComposableArchitecture", package: "swift-composable-architecture")
}
