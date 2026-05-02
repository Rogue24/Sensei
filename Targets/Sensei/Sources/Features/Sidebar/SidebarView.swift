import SwiftUI
import ComposableArchitecture

struct SidebarView: View {
    @Bindable var store: StoreOf<SidebarReducer>

    var body: some View {
        List(
            selection: Binding(
                get: { store.currentChatID },
                set: { store.send(.selectChat($0)) }
            )
        ) {
            ForEach(store.scope(state: \.chats, action: \.chatRow)) { chatStore in
                ChatRowView(store: chatStore)
            }
        }
        .toolbar {
            ToolbarItemGroup {
                Spacer()

                Button {
                    store.send(.updateNewChatPresented(true))
                } label: {
                    Image(systemName: "plus")
                }
                .help("New chat")
                .sheet(
                    isPresented: Binding(
                        get: { store.isNewChatPresented },
                        set: { store.send(.updateNewChatPresented($0)) }
                    )
                ) {
                    NewChatView(
                        cancelAction: {
                            store.send(.updateNewChatPresented(false))
                        },
                        doneAction: { localChat in
                            store.send(.createNewChat(localChat))
                            store.send(.updateNewChatPresented(false))
                        }
                    )
                }
            }
        }
        .alert($store.scope(state: \.alert, action: \.alert))
    }
}

struct SidebarView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationSplitView {
            SidebarView(
                store: Store(
                    initialState: SidebarReducer.State(
                        chats: [
                            .init(
                                id: .init(Int64(1)),
                                name: "闲聊",
                                model: .gpt_3_5_turbo,
                                prompt: "语言简洁易懂的博士",
                                temperature: 0.3,
                                numberOfMessagesInContext: 4,
                                updatedAt: .init()
                            ),
                        ],
                        currentChatID: nil,
                        isNewChatPresented: false,
                        alert: nil
                    )
                ) {
                    SidebarReducer()
                }
            )
            .frame(width: 200)
        } detail: {
            Text("Detail")
        }
        .frame(width: 400)
    }
}
