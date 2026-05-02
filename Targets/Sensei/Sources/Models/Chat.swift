import Foundation
import ComposableArchitecture
import Tagged

@ObservableState
struct Chat: Identifiable, Hashable, Sendable {
    typealias ID = Tagged<Chat, Int64>

    let id: ID
    var name: String
    var model: ChatGPTModel
    var prompt: String
    var temperature: Double
    var numberOfMessagesInContext: Int
    var updatedAt: Date
}

extension Chat {
    var localChat: LocalChat {
        .init(
            id: id.rawValue,
            name: name,
            model: model,
            prompt: prompt,
            temperature: temperature,
            numberOfMessagesInContext: numberOfMessagesInContext,
            updatedAt: updatedAt
        )
    }
}
