import SwiftUI
import ComposableArchitecture

struct ChatRowView: View {
    let store: StoreOf<ChatRowReducer>
    @State private var over = false

    var body: some View {
        HStack(spacing: 0) {
            Text(store.name)

            Spacer()

            Button {
                store.send(.tryDeleteChat)
            } label: {
                Image(systemName: "trash")
            }
            .buttonStyle(.borderless)
            .help("Delete")
            .opacity(over ? 1 : 0)
        }
        .onHover {
            over = $0
        }
        .tag(store.id)
    }
}

struct ChatRowView_Previews: PreviewProvider {
    static var previews: some View {
        ChatRowView(
            store: Store(
                initialState: .init(
                    id: .init(Int64(1)),
                    name: "闲聊",
                    model: .gpt_3_5_turbo,
                    prompt: "语言简洁易懂的博士",
                    temperature: 0.3,
                    numberOfMessagesInContext: 4,
                    updatedAt: .distantPast
                )
            ) {
                ChatRowReducer()
            }
        )
    }
}
