import SwiftUI
import ComposableArchitecture

struct DetailView: View {
    private enum FocusedField {
        case input
    }

    @Bindable var store: StoreOf<DetailReducer>

    @FocusState private var focusedField: FocusedField?

    var body: some View {
        ScrollViewReader { scrollViewProxy in
            messageScrollView(scrollViewProxy)
        }
        .navigationTitle(store.chat.name)
        .navigationSubtitle(store.chat.prompt)
        .toolbar {
            Button {
                store.send(.updateEditChatPresented(true))
            } label: {
                Image(systemName: "info.circle")
            }
            .help("Edit chat")

            Button {
                store.send(.tryClearAllMessages)
            } label: {
                Image(systemName: "xmark")
            }
            .disabled(store.messages.isEmpty)
            .help("Clear all messages")

            Button {
                store.send(.toggleTextModeEnabled)
            } label: {
                Image(systemName: "doc.plaintext")
                    .foregroundStyle(store.isTextModeEnabled ? Color.accentColor : Color.primary)
            }
            .disabled(store.messages.isEmpty)
            .help("Toggle text mode")

            Button {
                store.send(.updateFileExporterPresented(true))
            } label: {
                Image(systemName: "square.and.arrow.up")
            }
            .disabled(store.messages.isEmpty)
            .help("Export as Markdown")
        }
        .sheet(isPresented: editChatPresentedBinding) {
            EditChatView(
                chat: store.chat,
                cancelAction: cancelEditingChat,
                doneAction: updateChat
            )
        }
        .fileExporter(
            isPresented: fileExporterPresentedBinding,
            document: exportDocument,
            contentType: .markdown,
            defaultFilename: exportFilename,
            onCompletion: handleExport
        )
        .alert($store.scope(state: \.alert, action: \.alert))
    }

    private func messageScrollView(_ scrollViewProxy: ScrollViewProxy) -> some View {
        ScrollView {
            ZStack {
                Color.clear
                messageList
            }
        }
        .rotationEffect(.radians(.pi))
        .scaleEffect(x: -1, y: 1, anchor: .center)
        .background(Color(.textBackgroundColor))
        .onChange(of: store.animatedMessageToScrollTo) { _, value in
            scroll(to: value, using: scrollViewProxy)
        }
        .overlay {
            emptyStateOverlay
        }
        .overlay(alignment: .bottomTrailing) {
            sendModeHintOverlay
        }
        .safeAreaInset(edge: .bottom) {
            bottomInputBar
        }
        .overlay {
            textModeOverlay
        }
    }

    private var messageList: some View {
        VStack {
            ForEach(store.scope(state: \.messages, action: \.messageRow)) {
                MessageRowView(store: $0)
                    .rotationEffect(.radians(.pi))
                    .scaleEffect(x: -1, y: 1, anchor: .center)
            }
        }
        .padding(.horizontal)
    }

    @ViewBuilder
    private var emptyStateOverlay: some View {
        if store.messages.isEmpty {
            EmptyChatView()
        }
    }

    @ViewBuilder
    private var sendModeHintOverlay: some View {
        if !store.input.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            SendModeHintView(enterToSend: store.enterToSend)
                .padding(.horizontal, 8)
        }
    }

    @ViewBuilder
    private var textModeOverlay: some View {
        if store.isTextModeEnabled {
            TextEditor(text: .constant(store.chatContent))
                .font(.body)
        }
    }

    private func scroll(to value: AnimatedMessageToScrollTo?, using scrollViewProxy: ScrollViewProxy) {
        guard let value else { return }

        if value.animated {
            withAnimation {
                scrollViewProxy.scrollTo(value.message.id, anchor: value.anchor)
            }
        } else {
            scrollViewProxy.scrollTo(value.message.id, anchor: value.anchor)
        }

        store.send(.resetAnimatedMessageToScrollTo)
    }

    private var editChatPresentedBinding: Binding<Bool> {
        Binding<Bool>(
            get: { store.isEditChatPresented },
            set: { value in store.send(.updateEditChatPresented(value)) }
        )
    }

    private var fileExporterPresentedBinding: Binding<Bool> {
        Binding<Bool>(
            get: { store.isFileExporterPresented },
            set: { value in store.send(.updateFileExporterPresented(value)) }
        )
    }

    private var inputBinding: Binding<String> {
        Binding<String>(
            get: { store.input },
            set: { value in store.send(.updateInput(value)) }
        )
    }

    private var bottomInputBar: some View {
        HStack(spacing: 8) {
            if store.chat.numberOfMessagesInContext > 0 {
                forgetHistoryButton
            }

            InputEditor(
                placeholder: "What's in your mind?",
                text: inputBinding,
                enterToSend: store.enterToSend,
                newlineAction: sendInput
            )
            .focused($focusedField, equals: .input)
            .padding(.horizontal, 4)
            .padding(.vertical, 4)
            .background(Color(.textBackgroundColor), in: .rect(cornerRadius: 5))
            .frame(height: 56)
        }
        .padding(8)
        .background(.thinMaterial, in: Rectangle())
        .onAppear {
            focusedField = .input
        }
    }

    private var forgetHistoryButton: some View {
        Button(action: forgetHistory) {
            Image(systemName: "fish")
                .frame(height: 44)
        }
        .buttonStyle(.borderless)
        .help("Forget all history")
    }

    private func forgetHistory() {
        guard let last = store.messages.last else { return }
        guard last.source != .breaker, last.source != .receiving else { return }

        store.send(.breakChat)
    }

    private func sendInput() {
        store.send(.sendInputIfCan)
    }

    private func cancelEditingChat() {
        store.send(.updateEditChatPresented(false))
    }

    private func updateChat(_ chat: Chat) {
        store.send(.updateChat(chat))
        store.send(.updateEditChatPresented(false))
    }

    private var exportDocument: ChatDocument {
        ChatDocument(data: store.chatContent.data(using: .utf8))
    }

    private func handleExport(_ result: Result<URL, Error>) {
        #if DEBUG
        switch result {
        case .success(let url):
            print("Exported to \(url)")
        case .failure(let error):
            print(error.localizedDescription)
        }
        #endif
    }

    private var exportFilename: String {
        let now = Date()
        let year = now.formatted(.dateTime.year(.defaultDigits))
        let month = now.formatted(.dateTime.month(.twoDigits))
        let day = now.formatted(.dateTime.day(.twoDigits))
        let hour = now.formatted(.dateTime.hour(.twoDigits(amPM: .omitted)))
        let minute = now.formatted(.dateTime.minute(.twoDigits))
        let second = now.formatted(.dateTime.second(.twoDigits))

        return "\(store.chat.name)-\(year).\(month).\(day)-\(hour).\(minute).\(second)"
    }
}

private struct EmptyChatView: View {
    var body: some View {
        VStack {
            Text("🤖")
                .font(.system(size: 48))

            Text("How can I help you?")
                .bold()
        }
    }
}

private struct SendModeHintView: View {
    let enterToSend: Bool

    var body: some View {
        hint
            .padding(.vertical, 4)
            .padding(.horizontal, 8)
            .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 5))
    }

    private var hint: Text {
        if enterToSend {
            return Text("Enter").bold()
                + Text(" to Send, ")
                + Text("⇧ Enter").bold()
                + Text(" for Newline")
        } else {
            return Text("⇧ Enter").bold()
                + Text(" to Send, ")
                + Text("Enter").bold()
                + Text(" for Newline")
        }
    }
}

struct DetailView_Previews: PreviewProvider {
    static var previews: some View {
        DetailView(
            store: .init(
                initialState: DetailReducer.State(
                    chat: .init(
                        id: .init(Int64(1)),
                        name: "闲聊",
                        model: .gpt_3_5_turbo,
                        prompt: "语言简洁易懂的博士",
                        temperature: 0.3,
                        numberOfMessagesInContext: 4,
                        updatedAt: .distantPast
                    ),
                    messages: [
                        .init(
                            id: .init("1"),
                            chatID: .init(Int64(1)),
                            source: .me,
                            content: "你好"
                        ),
                        .init(
                            id: .init("2"),
                            chatID: .init(Int64(1)),
                            source: .sensei,
                            content: "你好，我能怎么帮助你？"
                        ),
                    ],
                    enterToSend: true,
                    input: "",
                    isEditChatPresented: false,
                    isTextModeEnabled: false,
                    isFileExporterPresented: false,
                    alert: nil
                )
            ) {
                DetailReducer()
            }
        )
        .frame(width: 400, height: 400)
    }
}
