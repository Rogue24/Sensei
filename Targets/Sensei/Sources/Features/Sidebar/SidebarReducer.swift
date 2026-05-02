import SwiftUI
import ComposableArchitecture

@Reducer
struct SidebarReducer {
    @Dependency(\.databaseManager) var databaseManager

    @ObservableState
    struct State: Equatable {
        var chats: IdentifiedArrayOf<Chat>
        var currentChatID: Chat.ID?
        var isNewChatPresented: Bool
        @Presents var alert: AlertState<Action.Alert>?
    }

    enum Action: Equatable {
        case selectChat(Chat.ID?)
        case tryDeleteChat(Chat)
        case deleteChat(Chat)
        case updateNewChatPresented(Bool)
        case createNewChat(LocalChat)
        case alert(PresentationAction<Alert>)
        case chatRow(IdentifiedActionOf<ChatRowReducer>)

        enum Alert: Equatable {
            case deleteChat(Chat)
        }
    }

    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .selectChat(let chat):
                state.currentChatID = chat
                return .none
            case .tryDeleteChat(let chat):
                state.alert = .init(
                    title: { .init("Delete \(chat.name)?") },
                    actions: {
                        ButtonState(role: .cancel) {
                            TextState("Cancel")
                        }

                        ButtonState(role: .destructive, action: .deleteChat(chat)) {
                            TextState("Delete")
                        }
                    }
                )

                return .none
            case .deleteChat(let chat):
                do {
                    try databaseManager.delete(chat.localChat)
                    state.chats.remove(id: chat.id)
                    state.currentChatID = state.chats.first?.id
                } catch {
                    print("error:", error)
                }

                return .none
            case .updateNewChatPresented(let isPresented):
                state.isNewChatPresented = isPresented
                return .none
            case .createNewChat(let localChat):
                do {
                    let localChat = try databaseManager.insert(localChat)
                    let chat = localChat.chat
                    state.chats.insert(chat, at: 0)
                    state.currentChatID = chat.id
                } catch {
                    print("error:", error)
                }

                return .none
            case .alert(.presented(.deleteChat(let chat))):
                return .send(.deleteChat(chat))
            case .alert:
                return .none
            case .chatRow(.element(id: let id, action: .tryDeleteChat)):
                if let chat = state.chats[id: id] {
                    state.alert = .init(
                        title: { .init("Delete \(chat.name)?") },
                        actions: {
                            ButtonState(role: .cancel) {
                                TextState("Cancel")
                            }

                            ButtonState(role: .destructive, action: .deleteChat(chat)) {
                                TextState("Delete")
                            }
                        }
                    )
                }

                return .none
            case .chatRow:
                return .none
            }
        }
        .ifLet(\.$alert, action: \.alert)
        .forEach(\.chats, action: \.chatRow) {
            ChatRowReducer()
        }
    }
}
