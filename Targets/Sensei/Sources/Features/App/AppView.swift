import SwiftUI
import ComposableArchitecture

struct AppView: View {
    let store: StoreOf<AppReducer>

    var body: some View {
        NavigationSplitView {
            SidebarView(
                store: store.scope(
                    state: \.sidebar,
                    action: \.sidebar
                )
            )
            .navigationSplitViewColumnWidth(min: 180, ideal: 220, max: 280)
        } detail: {
            if let detailStore = store.scope(state: \.detail, action: \.detail) {
                DetailView(store: detailStore)
            } else {
                Text("Select a chat or create a new one")
            }
        }
    }
}
