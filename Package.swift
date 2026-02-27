// swift-tools-version: 6.0
import PackageDescription
import AppleProductTypes

let package = Package(
    name: "Shwaas",
    platforms: [
        .iOS("16.0")
    ],
    products: [
        .iOSApplication(
            name: "Shwaas",
            targets: ["AppModule"],
            bundleIdentifier: "naman.Shwaas",
            teamIdentifier: "24959PJ5V3",
            displayVersion: "1.0",
            bundleVersion: "1",
            appIcon: .asset("AppIcon"),
            supportedDeviceFamilies: [
                .pad,
                .phone
            ],
            supportedInterfaceOrientations: [
                .portrait,
                .landscapeRight,
                .landscapeLeft,
                .portraitUpsideDown(.when(deviceFamilies: [.pad]))
            ],
            appCategory: .healthcareFitness
        )
    ],
    targets: [
        .executableTarget(
            name: "AppModule",
            path: ".",
            resources: [
                .process("Assets.xcassets")
            ]
        )
    ],
    swiftLanguageVersions: [.version("6")]
)
