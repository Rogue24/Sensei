import SwiftUI
import ComposableArchitecture
import MarkdownUI

struct MessageRowView: View {
    let store: StoreOf<MessageRowReducer>
    @Environment(\.colorScheme) private var colorScheme
    @State private var over = false

    var body: some View {
        Group {
            switch store.source {
            case .me:
                HStack(spacing: 0) {
                    Spacer(minLength: 20)

                    Button {
                        store.send(.tryClearFromBottomToThisMessage)
                    } label: {
                        Image(systemName: "xmark")
                            .opacity(over ? 1 : 0)
                    }
                    .help("Clear from bottom to this message")
                    .buttonStyle(.borderless)
                    .padding(.trailing, 10)

                    Button {
                        store.send(.copyMessage)
                    } label: {
                        Image(systemName: "doc.on.doc")
                            .opacity(over ? 1 : 0)
                    }
                    .help("Copy")
                    .buttonStyle(.borderless)
                    .padding(.trailing, 10)

                    Text(store.content)
                        .textSelection(.enabled)
                        .lineSpacing(4)
                        .foregroundStyle(Color.accentColor)
                        .padding(.vertical, 8)
                        .padding(.horizontal, 12)
                        .background(
                            RoundedRectangle(cornerRadius: 10, style: .continuous)
                                .fill(Color.accentColor.opacity(over ? 0.1 : 0.05))
                        )
                }
            case .sensei:
                HStack(spacing: 0) {
                    Markdown(.init(store.content))
                        .markdownTheme(.sensei)
                        .markdownCodeSyntaxHighlighter(.sensei(colorScheme: colorScheme))
                        .textSelection(.enabled)
                        .padding(.vertical, 8)
                        .padding(.horizontal, 12)
                        .background(
                            RoundedRectangle(cornerRadius: 10, style: .continuous)
                                .fill(Color.gray.opacity(over ? 0.1 : 0.05))
                        )

                    Button {
                        store.send(.copyMessage)
                    } label: {
                        Image(systemName: "doc.on.doc")
                            .opacity(over ? 1 : 0)
                    }
                    .help("Copy")
                    .buttonStyle(.borderless)
                    .padding(.leading, 10)

                    Spacer(minLength: 20)
                }
            case .error:
                HStack(spacing: 0) {
                    HStack(spacing: 8) {
                        Text(store.content)
                            .lineSpacing(4)
                            .foregroundStyle(.red)
                            .padding(.vertical, 8)
                            .padding(.horizontal, 12)
                            .background(
                                RoundedRectangle(cornerRadius: 10, style: .continuous)
                                    .fill(Color.red.opacity(over ? 0.1 : 0.05))
                            )

                        Button {
                            store.send(.retryChatIfCan)
                        } label: {
                            Image(systemName: "arrow.triangle.2.circlepath")
                        }
                        .buttonStyle(.borderless)
                        .help("Retry")
                    }

                    Spacer(minLength: 20)
                }
            case .breaker:
                HStack(spacing: 2) {
                    Color.gray.opacity(over ? 0.5 : 0.35).frame(height: 1)

                    Image(systemName: "fish")
                    Image(systemName: "fish")
                    Image(systemName: "fish")

                    Color.gray.opacity(over ? 0.5 : 0.35).frame(height: 1)
                }
            case .receiving:
                HStack(spacing: 0) {
                    ProgressView()
                        .scaleEffect(.init(width: 0.6, height: 0.6))
                        .background(
                            RoundedRectangle(cornerRadius: 10, style: .continuous)
                                .fill(Color.gray.opacity(over ? 0.1 : 0.05))
                        )

                    Spacer()
                }
            }
        }
        .onHover {
            over = $0
        }
        .id(store.id)
    }
}

struct MessageRowView_Previews: PreviewProvider {
    static var previews: some View {
        List {
            MessageRowView(
                store: Store(
                    initialState: .init(
                        id: .init("1"),
                        chatID: .init(Int64(1)),
                        source: .me,
                        content: "Hello"
                    )
                ) {
                    MessageRowReducer()
                }
            )

            MessageRowView(
                store: Store(
                    initialState: .init(
                        id: .init("2"),
                        chatID: .init(Int64(1)),
                        source: .sensei,
                        content: "How do you do?"
                    )
                ) {
                    MessageRowReducer()
                }
            )

            MessageRowView(
                store: Store(
                    initialState: .init(
                        id: .init("3"),
                        chatID: .init(Int64(1)),
                        source: .error,
                        content: "Error"
                    )
                ) {
                    MessageRowReducer()
                }
            )

            MessageRowView(
                store: Store(
                    initialState: .init(
                        id: .init("4"),
                        chatID: .init(Int64(1)),
                        source: .receiving,
                        content: ""
                    )
                ) {
                    MessageRowReducer()
                }
            )
        }
        .frame(width: 400, height: 400)
    }
}
