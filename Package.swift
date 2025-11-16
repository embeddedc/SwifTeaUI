// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "SwifTeaUI",
    platforms: [.macOS(.v14)],
    products: [
        // Users typically `import SwifTeaUI` (which depends on SwifTeaCore)
        .library(name: "SwifTeaUI", targets: ["SwifTeaUI"]),
        .library(name: "SwifTeaCore", targets: ["SwifTeaCore"]),
        .executable(name: "SwifTeaNotebookExample", targets: ["SwifTeaNotebookExample"]),
        .executable(name: "SwifTeaTaskRunnerExample", targets: ["SwifTeaTaskRunnerExample"]),
        .executable(name: "SwifTeaPackageListExample", targets: ["SwifTeaPackageListExample"]),
        .executable(name: "SwifTeaShowcaseExample", targets: ["SwifTeaShowcaseExample"])
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-testing.git", branch: "main")
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
            name: "SwifTeaNotebookExample",
            dependencies: ["SwifTeaUI"],
            path: "Sources/Examples/Notebook"
        ),
        .executableTarget(
            name: "SwifTeaTaskRunnerExample",
            dependencies: ["SwifTeaUI"],
            path: "Sources/Examples/TaskRunner"
        ),
        .executableTarget(
            name: "SwifTeaPackageListExample",
            dependencies: ["SwifTeaUI"],
            path: "Sources/Examples/PackageList"
        ),
        .executableTarget(
            name: "SwifTeaShowcaseExample",
            dependencies: ["SwifTeaUI"],
            path: "Sources/Examples/Showcase"
        ),
        .target(
            name: "SnapshotTestSupport",
            dependencies: [
                "SwifTeaUI",
                .product(name: "Testing", package: "swift-testing")
            ],
            path: "Tests/TestSupport"
        ),
        .testTarget(
            name: "SwifTeaCoreTests",
            dependencies: [
                "SwifTeaCore",
                "SwifTeaUI",
                .product(name: "Testing", package: "swift-testing")
            ]
        ),
        .testTarget(
            name: "SwifTeaUITests",
            dependencies: [
                "SwifTeaUI",
                "SnapshotTestSupport",
                .product(name:"Testing", package: "swift-testing")
            ]
        ),
        .testTarget(
            name: "SwifTeaNotebookExampleTests",
            dependencies: [
                "SwifTeaNotebookExample",
                "SnapshotTestSupport",
                .product(name: "Testing", package: "swift-testing")
            ]
        ),
        .testTarget(
            name: "SwifTeaTaskRunnerExampleTests",
            dependencies: [
                "SwifTeaTaskRunnerExample",
                "SnapshotTestSupport",
                .product(name: "Testing", package: "swift-testing")
            ]
        )
    ],
)
