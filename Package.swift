// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "SwifTeaUI",
    platforms: [.macOS(.v12)],
    products: [
        // Users typically `import SwifTeaUI` (which depends on SwifTeaCore)
        .library(name: "SwifTeaUI", targets: ["SwifTeaUI"]),
        .library(name: "SwifTeaCore", targets: ["SwifTeaCore"]),
        .executable(name: "SwifTeaCounterExample", targets: ["SwifTeaCounterExample"])
    ],
    targets: [
        .target(
            name: "SwifTeaCore",
            path: "Sources/SwifTeaCore"
        ),
        .target(
            name: "SwifTeaUI",
            dependencies: ["SwifTeaCore"],
            path: "Sources/SwifTeaUI"
        ),
        .executableTarget(
            name: "SwifTeaCounterExample",
            dependencies: ["SwifTeaUI"],
            path: "Sources/Examples/Counter"
        ),
        .testTarget(
            name: "SwifTeaCoreTests",
            dependencies: ["SwifTeaCore"]
        ),
        .testTarget(
            name: "SwifTeaUITests",
            dependencies: ["SwifTeaUI"]
        )
    ]
)

