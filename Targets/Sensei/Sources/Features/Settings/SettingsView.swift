import SwiftUI
import ComposableArchitecture

struct SettingsView: View {
    let store: StoreOf<SettingsReducer>

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                Text("Custom Host")

                TextField(
                    "api.openai.com",
                    text: Binding(
                        get: { store.customHost },
                        set: { store.send(.updateCustomHost($0)) }
                    )
                )
                .textFieldStyle(.plain)
                .padding(8)
                .background(Color(.textBackgroundColor), in: .rect(cornerRadius: 5))
            }

            VStack(alignment: .leading, spacing: 4) {
                Text("API Key")

                TextField(
                    "sk-",
                    text: Binding(
                        get: { store.apiKey },
                        set: { store.send(.updateAPIKey($0)) }
                    )
                )
                .textFieldStyle(.plain)
                .padding(8)
                .background(Color(.textBackgroundColor), in: .rect(cornerRadius: 5))
            }

            VStack(alignment: .leading, spacing: 4) {
                Text("Send Mode")

                Picker(
                    "",
                    selection: Binding(
                        get: { store.enterToSend },
                        set: { store.send(.updateEnterToSend($0)) }
                    )
                ) {
                    Text("Enter to Send").tag(true)
                    Text("⇧ Enter to Send").tag(false)
                }
                .labelsHidden()
                .pickerStyle(.segmented)
                .padding(8)
                .background(Color(.textBackgroundColor), in: .rect(cornerRadius: 5))
            }

            Spacer()
        }
        .padding()
    }
}
