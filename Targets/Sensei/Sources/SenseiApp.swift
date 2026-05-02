import SwiftUI
import AppKit
import ComposableArchitecture

@main
struct SenseiApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @Environment(\.openURL) private var openURL
    private let store: StoreOf<AppReducer> = .init(
        initialState: .init(
            databaseManager: .shared
        )
    ) {
        AppReducer()
    }

    var body: some Scene {
        WindowGroup {
            AppView(store: store)
        }
        .commands {
            CommandGroup(before: .help) {
                Button("Source Code") {
                    openURL(.init(string: "https://github.com/nixzhu/Sensei")!)
                }
                .keyboardShortcut("/", modifiers: .command)
            }
        }

        SwiftUI.Settings {
            SettingsView(
                store: store.scope(
                    state: \.settings,
                    action: \.settings
                )
            )
            .frame(width: 360, height: 220)
        }
    }
}

final class AppDelegate: NSObject, NSApplicationDelegate {
    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        true
    }
}
