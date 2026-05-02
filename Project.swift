import ProjectDescription

let name = "Sensei"

let project = Project(
    name: name,
    organizationName: "nixzhu",
    options: .options(
        disableSynthesizedResourceAccessors: true
    ),
    packages: [
        .remote(
            url: "https://github.com/nixzhu/Ananda.git",
            requirement: .upToNextMajor(from: "0.1.1")
        ),
        .remote(
            url: "https://github.com/pointfreeco/swift-composable-architecture.git",
            requirement: .exact("1.25.5")
        ),
        .remote(
            url: "https://github.com/pointfreeco/swift-custom-dump.git",
            requirement: .upToNextMajor(from: "1.3.2")
        ),
        .remote(
            url: "https://github.com/pointfreeco/swift-tagged.git",
            requirement: .upToNextMajor(from: "0.10.0")
        ),
        .remote(
            url: "https://github.com/gonzalezreal/swift-markdown-ui.git",
            requirement: .upToNextMajor(from: "2.1.0")
        ),
        .remote(
            url: "https://github.com/groue/GRDB.swift.git",
            requirement: .upToNextMajor(from: "6.10.1")
        ),
    ],
    targets: [
        .target(
            name: name,
            destinations: .macOS,
            product: .app,
            bundleId: {
                let bundleIDPrefix = Environment.bundleIDPrefix.getString(default: "")

                if bundleIDPrefix.isEmpty {
                    return "io.tuist.\(name)"
                } else {
                    return "\(bundleIDPrefix).\(name)"
                }
            }(),
            deploymentTargets: .macOS("14.0"),
            infoPlist: .extendingDefault(with: [
                "CFBundleShortVersionString": .string(
                    {
                        let string = Environment.version.getString(default: "")

                        if string.isEmpty {
                            return "0.3.0"
                        } else {
                            return string
                        }
                    }()
                ),
                "CFBundleVersion": .string(
                    {
                        let string = Environment.build.getString(default: "")

                        if string.isEmpty {
                            return "9"
                        } else {
                            return string
                        }
                    }()
                ),
                "NSMainStoryboardFile": "",
                "UILaunchStoryboardName": "LaunchScreen",
                "NSHumanReadableCopyright": "Copyright @nixzhu. All rights reserved.",
            ]),
            sources: ["Targets/\(name)/Sources/**"],
            resources: ["Targets/\(name)/Resources/**"],
            dependencies: [
                .package(product: "Ananda"),
                .package(product: "ComposableArchitecture"),
                .package(product: "CustomDump"),
                .package(product: "Tagged"),
                .package(product: "MarkdownUI"),
                .package(product: "GRDB"),
            ],
            settings: .settings(
                base: .init()
                    .swiftVersion("6.0")
                    .swiftStrictConcurrency(.complete)
                    .enableActorDataRaceChecks(),
                defaultSettings: .recommended
            )
        ),
    ]
)

extension SettingsDictionary {
    func swiftVersion(_ value: String) -> SettingsDictionary {
        var info = self
        info["SWIFT_VERSION"] = .string(value)

        return info
    }

    enum SwiftStrictConcurrency: String {
        case minimal
        case targeted
        case complete
    }

    func swiftStrictConcurrency(_ value: SwiftStrictConcurrency) -> SettingsDictionary {
        var info = self
        info["SWIFT_STRICT_CONCURRENCY"] = .string(value.rawValue)

        return info
    }

    func enableActorDataRaceChecks() -> SettingsDictionary {
        var info = self
        info["ENABLE_ACTOR_DATA_RACE_CHECKS"] = .string("YES")

        return info
    }
}
