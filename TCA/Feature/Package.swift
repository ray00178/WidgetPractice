// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
  name: "Feature",
  platforms: [.iOS(.v17)],
  products: [
    // Products define the executables and libraries a package produces, making them visible to other packages.
    .library(name: "Feature", targets: ["Feature"]),
    .library(name: "ContentBlockerService", targets: ["ContentBlockerService"]),
  ],
  dependencies: [
    .package(url: "https://github.com/pointfreeco/swift-composable-architecture", exact: "1.3.0"),
    .package(url: "https://github.com/pointfreeco/swift-dependencies", from: "1.0.0"),
  ],
  targets: [
    // Targets are the basic building blocks of a package, defining a module or a test suite.
    // Targets can depend on other targets in this package and products from dependencies.
    .target(name: "Feature", dependencies: [.tca, "ContentBlockerService"]),
    .testTarget(name: "FeatureTests", dependencies: ["Feature", .tca]),
    .target(name: "ContentBlockerService", dependencies: [.dependencies]),
  ]
)

extension Target.Dependency {
  static let tca = Self.product(name: "ComposableArchitecture", package: "swift-composable-architecture")
  static let dependencies = Self.product(name: "Dependencies", package: "swift-dependencies")
}
